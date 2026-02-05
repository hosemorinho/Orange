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
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_alert.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailPrefixController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _emailCodeController = TextEditingController();
  bool _isRegistering = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSendingEmailCode = false;
  int _countdown = 0;
  String? _selectedEmailSuffix;

  // Alert state for inline notifications
  AuthAlertType? _alertType;
  String? _alertMessage;

  @override
  void initState() {
    super.initState();
    _emailPrefixController.addListener(() {
      setState(() {});
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

  String get _fullEmail {
    final prefix = _emailPrefixController.text.trim();
    final suffix = _selectedEmailSuffix ?? '';
    if (prefix.isEmpty || suffix.isEmpty) return '';
    return '$prefix@$suffix';
  }

  Future<void> _register() async {
    final configAsync = ref.read(configProvider);
    final config = configAsync.value;
    final isInviteForce = config?['is_invite_force'] == 1;
    final isEmailVerify = config?['is_email_verify'] == 1;

    if (isInviteForce && _inviteCodeController.text.trim().isEmpty) {
      _showInviteCodeDialog();
      return;
    }

    if (isEmailVerify && _emailCodeController.text.trim().isEmpty) {
      XBoardNotification.showError(
          appLocalizations.pleaseEnterEmailVerificationCode);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isRegistering = true);
      try {
        final api = await ref.read(xboardSdkProvider.future);
        final json = await api.register(
          _fullEmail,
          _passwordController.text,
          inviteCode: _inviteCodeController.text.trim().isNotEmpty
              ? _inviteCodeController.text
              : null,
          emailCode:
              isEmailVerify && _emailCodeController.text.trim().isNotEmpty
                  ? _emailCodeController.text
                  : null,
        );

        final data = json['data'] as Map<String, dynamic>? ?? {};
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await api.saveAndSetToken(token, email: _fullEmail);
        }

        if (mounted) {
          final storageService = ref.read(storageServiceProvider);
          await storageService.saveCredentials(
              _fullEmail, _passwordController.text, true);
          if (mounted) {
            setState(() {
              _alertType = AuthAlertType.success;
              _alertMessage = appLocalizations.xboardRegisterSuccess;
            });
            XBoardNotification.showSuccess(
                appLocalizations.xboardRegisterSuccess);
          }
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.pop();
          });
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = appLocalizations.xboardRegisterFailed;
          if (e is V2BoardApiException) {
            errorMessage = e.message;
          } else {
            final errorStr = e.toString();
            if (errorStr.startsWith('Error: ')) {
              errorMessage = errorStr.substring(7);
            } else if (errorStr.startsWith('Exception: ')) {
              errorMessage = errorStr.substring(11);
            } else {
              errorMessage = errorStr;
            }
          }
          if (errorMessage.contains('遇到了些问题') ||
              errorMessage.contains('500')) {
            errorMessage = appLocalizations.inviteCodeIncorrect;
          }
          setState(() {
            _alertType = AuthAlertType.error;
            _alertMessage = errorMessage;
          });
          XBoardNotification.showError(errorMessage);
        }
      } finally {
        if (mounted) setState(() => _isRegistering = false);
      }
    }
  }

  Future<void> _sendEmailCode() async {
    if (_emailPrefixController.text.trim().isEmpty) {
      XBoardNotification.showError(appLocalizations.pleaseEnterEmailAddress);
      return;
    }
    if (_selectedEmailSuffix == null || _selectedEmailSuffix!.isEmpty) {
      XBoardNotification.showError(appLocalizations.pleaseSelectEmailSuffix);
      return;
    }

    setState(() => _isSendingEmailCode = true);
    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.sendEmailVerify(_fullEmail);
      if (mounted) {
        XBoardNotification.showSuccess(
            appLocalizations.verificationCodeSentCheckEmail);
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        XBoardNotification.showError(
            appLocalizations.sendVerificationCodeFailed(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isSendingEmailCode = false);
    }
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    });
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
              onPressed: () => context.pop(),
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
    final textTheme = Theme.of(context).textTheme;
    final configAsync = ref.watch(configProvider);

    return configAsync.when(
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _buildPage(context, colorScheme, textTheme, null),
      data: (config) => _buildPage(context, colorScheme, textTheme, config),
    );
  }

  Widget _buildPage(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, Map<String, dynamic>? config) {
    return AuthScaffold(
      showBackButton: true,
      onBack: () => context.pop(),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: centered title + subtitle
            Text(
              appLocalizations.createAccount,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.fillInfoToRegister,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Alert notification (matching frontend inline alert)
            if (_alertMessage != null) ...[
              AuthAlert(
                type: _alertType!,
                message: _alertMessage!,
                onClose: () => setState(() => _alertMessage = null),
              ),
              const SizedBox(height: 24),
            ],

            // Email input (prefix + @ + suffix dropdown)
            _buildEmailInput(context, colorScheme, textTheme, config),
            const SizedBox(height: 20),

            // Password
            XBInputField(
              controller: _passwordController,
              labelText: appLocalizations.password,
              hintText: appLocalizations.pleaseEnterAtLeast8CharsPassword,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
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

            // Confirm Password
            XBInputField(
              controller: _confirmPasswordController,
              labelText: appLocalizations.confirmNewPassword,
              hintText: appLocalizations.pleaseReEnterPassword,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () {
                  setState(() =>
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
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

            // Invite code
            XBInputField(
              controller: _inviteCodeController,
              labelText: (config?['is_invite_force'] == 1)
                  ? '${appLocalizations.xboardInviteCode} *'
                  : appLocalizations.inviteCodeOptional,
              hintText: appLocalizations.pleaseEnterInviteCode,
              enabled: true,
            ),

            // Invite code helper text (matching frontend orange helper)
            if (config?['is_invite_force'] == 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  appLocalizations.inviteCodeRequiredMessage,
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFea580c), // text-orange-600
                  ),
                ),
              ),

            // Email verification code (if enabled)
            if (config?['is_email_verify'] == 1) ...[
              const SizedBox(height: 20),
              _buildEmailCodeField(context, colorScheme, textTheme),
            ],

            const SizedBox(height: 24),

            // Register button
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: !_isRegistering ? _register : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor:
                      colorScheme.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isRegistering
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        appLocalizations.registerAccount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer: "Already have account? Login"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${appLocalizations.alreadyHaveAccount} ',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    appLocalizations.loginNow,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Email input: prefix + @ + suffix dropdown
  /// Matching frontend's EmailInput component with whitelist support
  Widget _buildEmailInput(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, Map<String, dynamic>? config) {
    final emailSuffixes =
        (config?['email_whitelist_suffix'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

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

    if (_selectedEmailSuffix == null && emailSuffixes.isNotEmpty) {
      _selectedEmailSuffix = emailSuffixes.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (matching: text-sm font-medium)
        Text(
          appLocalizations.emailAddress,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        // Input row: prefix + @ + suffix
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email prefix input
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _emailPrefixController,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: appLocalizations.emailPrefixHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  isDense: true,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return appLocalizations.pleaseEnterEmailPrefix;
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
                    return appLocalizations.invalidEmailFormat;
                  }
                  return null;
                },
              ),
            ),
            // @ symbol
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
              child: Text(
                '@',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Suffix dropdown
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedEmailSuffix,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  isDense: true,
                ),
                items: emailSuffixes.map((suffix) {
                  return DropdownMenuItem(
                    value: suffix,
                    child: Text(
                      suffix,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedEmailSuffix = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.pleaseSelectSuffix;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        // Full email preview
        if (_emailPrefixController.text.isNotEmpty &&
            _selectedEmailSuffix != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              appLocalizations.fullEmailPreview(_fullEmail),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// Email code field with inline send button
  /// Matching frontend pattern: flex gap-2, input flex-1 + Button variant=outline
  Widget _buildEmailCodeField(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          appLocalizations.emailVerificationCode,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailCodeController,
                keyboardType: TextInputType.number,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: appLocalizations.pleaseEnterEmailVerificationCode,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  isDense: true,
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
            ),
            const SizedBox(width: 8),
            // Send code button (matching: Button variant=outline)
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed:
                    (_countdown > 0 || _isSendingEmailCode) ? null : _sendEmailCode,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSendingEmailCode
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Text(
                        _countdown > 0
                            ? '${_countdown}s'
                            : appLocalizations.sendVerificationCode,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
