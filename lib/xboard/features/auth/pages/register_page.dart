import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:go_router/go_router.dart';
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailPrefixController = TextEditingController(); // 邮箱前缀（@之前的部分）
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _emailCodeController = TextEditingController();
  bool _isRegistering = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSendingEmailCode = false;
  String? _selectedEmailSuffix; // 选中的邮箱后缀

  @override
  void initState() {
    super.initState();
    // 监听邮箱前缀输入，实时更新预览
    _emailPrefixController.addListener(() {
      setState(() {
        // 触发重建以更新完整邮箱预览
      });
    });
  }

  @override
  void dispose() {
    _emailPrefixController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    _emailCodeController.dispose();
    super.dispose();
  }

  /// 获取完整的邮箱地址
  String get _fullEmail {
    final prefix = _emailPrefixController.text.trim();
    final suffix = _selectedEmailSuffix ?? '';
    if (prefix.isEmpty || suffix.isEmpty) return '';
    return '$prefix@$suffix';
  }
  Future<void> _register() async {
    // 获取配置
    final configAsync = ref.read(configProvider);
    final config = configAsync.value;
    final isInviteForce = config?['is_invite_force'] == 1;
    final isEmailVerify = config?['is_email_verify'] == 1;

    // 检查邀请码是否必填
    if (isInviteForce && _inviteCodeController.text.trim().isEmpty) {
      _showInviteCodeDialog();
      return;
    }

    // 检查邮箱验证码是否必填
    if (isEmailVerify && _emailCodeController.text.trim().isEmpty) {
      XBoardNotification.showError('请输入邮箱验证码');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });
      try {
        // 使用 V2Board API 注册
        final api = await ref.read(xboardSdkProvider.future);
        final json = await api.register(
          _fullEmail, // 使用组合后的完整邮箱
          _passwordController.text,
          inviteCode: _inviteCodeController.text.trim().isNotEmpty
              ? _inviteCodeController.text
              : null,
          emailCode: isEmailVerify && _emailCodeController.text.trim().isNotEmpty
              ? _emailCodeController.text
              : null,
        );

        // V2Board register returns token on success
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await api.saveAndSetToken(token);
        }

        // 注册成功
        if (mounted) {
          final storageService = ref.read(storageServiceProvider);
          await storageService.saveCredentials(
            _fullEmail, // 使用完整邮箱保存凭据
            _passwordController.text,
            true, // 启用记住密码
          );
          if (mounted) {
            XBoardNotification.showSuccess(appLocalizations.xboardRegisterSuccess);
          }
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.pop();
            }
          });
        }
      } catch (e) {
        if (mounted) {
          // 提取详细的错误信息
          String errorMessage = '注册失败';

          if (e is V2BoardApiException) {
            errorMessage = e.message;
          } else {
            final errorStr = e.toString();
            // 移除可能的 "Error: " 前缀
            if (errorStr.startsWith('Error: ')) {
              errorMessage = errorStr.substring(7);
            } else if (errorStr.startsWith('Exception: ')) {
              errorMessage = errorStr.substring(11);
            } else {
              errorMessage = errorStr;
            }
          }

          // 500错误或通用错误提示：可能是邀请码问题
          if (errorMessage.contains('遇到了些问题') || errorMessage.contains('500')) {
            errorMessage = appLocalizations.inviteCodeIncorrect;
          }

          XBoardNotification.showError(errorMessage);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
      }
    }
  }

  Future<void> _sendEmailCode() async {
    if (_emailPrefixController.text.trim().isEmpty) {
      XBoardNotification.showError(appLocalizations.pleaseEnterEmailAddress);
      return;
    }

    if (_selectedEmailSuffix == null || _selectedEmailSuffix!.isEmpty) {
      XBoardNotification.showError('请选择邮箱后缀');
      return;
    }

    setState(() {
      _isSendingEmailCode = true;
    });

    try {
      // 使用 V2Board API 发送验证码
      final api = await ref.read(xboardSdkProvider.future);
      await api.sendEmailVerify(_fullEmail);

      if (mounted) {
        XBoardNotification.showSuccess(appLocalizations.verificationCodeSentCheckEmail);
      }
    } catch (e) {
      if (mounted) {
        XBoardNotification.showError(appLocalizations.sendVerificationCodeFailed(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingEmailCode = false;
        });
      }
    }
  }

  /// 构建邮箱输入组件（前缀 + 后缀选择）
  Widget _buildEmailInput(BuildContext context, ColorScheme colorScheme, Map<String, dynamic>? config) {
    // 获取邮箱后缀白名单
    final emailSuffixes = (config?['email_whitelist_suffix'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // 如果配置中没有白名单，使用默认列表
    if (emailSuffixes.isEmpty) {
      emailSuffixes.addAll([
        'gmail.com',
        'outlook.com',
        'qq.com',
        '163.com',
        'foxmail.com',
        'icloud.com',
      ]);
    }

    // 如果还没有选中后缀，默认选中第一个
    if (_selectedEmailSuffix == null && emailSuffixes.isNotEmpty) {
      _selectedEmailSuffix = emailSuffixes.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.emailAddress,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 邮箱前缀输入框
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _emailPrefixController,
                decoration: InputDecoration(
                  hintText: '用户名',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入邮箱用户名';
                  }
                  // 验证邮箱前缀格式（只允许字母、数字、点、下划线、连字符）
                  if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
                    return '邮箱格式不正确';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            // @ 符号
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                '@',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 邮箱后缀下拉选择
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedEmailSuffix,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                items: emailSuffixes.map((suffix) {
                  return DropdownMenuItem(
                    value: suffix,
                    child: Text(
                      suffix,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmailSuffix = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择后缀';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        // 显示完整邮箱预览
        if (_emailPrefixController.text.isNotEmpty && _selectedEmailSuffix != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '完整邮箱: $_fullEmail',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _showInviteCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.inviteCodeRequired),
          content: Text(appLocalizations.inviteCodeRequiredMessage),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(appLocalizations.iUnderstand),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final configAsync = ref.watch(configProvider);

    // 处理异步加载状态
    return configAsync.when(
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _buildPage(context, colorScheme, null),
      data: (config) => _buildPage(context, colorScheme, config),
    );
  }

  Widget _buildPage(BuildContext context, ColorScheme colorScheme, Map<String, dynamic>? config) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: XBContainer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerLow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    appLocalizations.createAccount,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          appLocalizations.fillInfoToRegister,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // 邮箱输入（前缀 + 后缀选择）
                        _buildEmailInput(context, colorScheme, config),
                        const SizedBox(height: 20),
                        XBInputField(
                          controller: _passwordController,
                          labelText: appLocalizations.password,
                          hintText: appLocalizations.pleaseEnterAtLeast8CharsPassword,
                          prefixIcon: Icons.lock_outlined,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appLocalizations.pleaseEnterPassword;
                            }
                            if (value.length < 8) {
                              return appLocalizations.passwordMin8Chars;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        XBInputField(
                          controller: _confirmPasswordController,
                          labelText: appLocalizations.confirmNewPassword,
                          hintText: appLocalizations.pleaseReEnterPassword,
                          prefixIcon: Icons.lock_outlined,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appLocalizations.pleaseConfirmPassword;
                            }
                            if (value != _passwordController.text) {
                              return appLocalizations.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // 根据配置决定是否显示邮箱验证码字段
                        if (config?['is_email_verify'] == 1)
                          Column(
                            children: [
                                  XBInputField(
                                    controller: _emailCodeController,
                                    labelText: appLocalizations.emailVerificationCode,
                                    hintText: appLocalizations.pleaseEnterEmailVerificationCode,
                                    prefixIcon: Icons.verified_user_outlined,
                                    keyboardType: TextInputType.number,
                                    suffixIcon: _isSendingEmailCode
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : TextButton(
                                            onPressed: _sendEmailCode,
                                            child: Text(appLocalizations.sendVerificationCode),
                                          ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return appLocalizations.pleaseEnterEmailVerificationCode;
                                      }
                                      if (value.length != 6) {
                                        return appLocalizations.verificationCode6Digits;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                            ],
                          ),
                        // 邀请码：始终显示，根据配置改变标签（必填 vs 可选）
                        XBInputField(
                          controller: _inviteCodeController,
                          labelText: (config?['is_invite_force'] == 1)
                              ? '${appLocalizations.xboardInviteCode} *'
                              : appLocalizations.inviteCodeOptional,
                          hintText: appLocalizations.pleaseEnterInviteCode,
                          prefixIcon: Icons.card_giftcard_outlined,
                          enabled: true,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: _isRegistering
                              ? ElevatedButton(
                                  onPressed: null,
                                  child: const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    appLocalizations.registerAccount,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              appLocalizations.alreadyHaveAccount,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                appLocalizations.loginNow,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
