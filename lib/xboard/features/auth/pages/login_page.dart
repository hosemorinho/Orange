
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/initialization/initialization.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberPassword = false;
  bool _isPasswordVisible = false;
  late XBoardStorageService _storageService;
  
  @override
  void initState() {
    super.initState();
    _storageService = ref.read(storageServiceProvider);
    _loadSavedCredentials();

    // ✅ 调用统一初始化服务
    _initializeXBoard();
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  /// 初始化 XBoard（统一入口）
  Future<void> _initializeXBoard() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(initializationProvider.notifier).initialize();
      } catch (e) {
        // 初始化失败，UI 会显示错误状态
      }
    });
  }
  void refreshCredentials() {
    _loadSavedCredentials();
  }
  Future<void> _loadSavedCredentials() async {
    try {
      final savedEmail = await _storageService.getSavedEmail();
      final savedPassword = await _storageService.getSavedPassword();
      final rememberPassword = await _storageService.getRememberPassword();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
      if (savedPassword != null && savedPassword.isNotEmpty && rememberPassword) {
        _passwordController.text = savedPassword;
      }
      _rememberPassword = rememberPassword;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // 忽略加载凭据失败,继续正常流程
    }
  }
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // 如果尚未初始化，先尝试初始化
      final initState = ref.read(initializationProvider);
      if (!initState.isReady) {
        try {
          await ref.read(initializationProvider.notifier).refresh();
        } catch (e) {
          if (mounted) {
            XBoardNotification.showError('${appLocalizations.xboardLoginFailed}: $e');
          }
          return;
        }
        // 再次检查初始化是否成功
        final updatedState = ref.read(initializationProvider);
        if (!updatedState.isReady) {
          if (mounted) {
            XBoardNotification.showError(updatedState.errorMessage ?? appLocalizations.xboardLoginFailed);
          }
          return;
        }
      }

      final userNotifier = ref.read(xboardUserProvider.notifier);
      final success = await userNotifier.login(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        if (success) {
          if (_rememberPassword) {
            await _storageService.saveCredentials(
              _emailController.text,
              _passwordController.text,
              true,
            );
          } else {
            await _storageService.saveCredentials(
              _emailController.text,
              '',
              false,
            );
          }
          if (mounted) {
            XBoardNotification.showSuccess(appLocalizations.xboardLoginSuccess);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go('/');
              }
            });
          }
        } else {
          final userState = ref.read(xboardUserProvider);
          if (userState.errorMessage != null) {
            // 使用 FlClash 的原生 Toast 通知（自动消失）
            XBoardNotification.showError(userState.errorMessage!);
          }
        }
      }
    }
  }
  void _navigateToRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
    _loadSavedCredentials();
    _initializeXBoard(); // 重新初始化
  }
  
  void _navigateToForgotPassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
    _initializeXBoard(); // 重新初始化
  }
    @override
    Widget build(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      final initState = ref.watch(initializationProvider);
      final userState = ref.watch(xboardUserProvider);
  
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            const LanguageSelector(),
            const SizedBox(width: 8),
            // ✅ 显示初始化状态指示器
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildInitializationIndicator(initState),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          color: colorScheme.surface,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xff0369A1),
                                      const Color(0xff0EA5E9),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.vpn_lock_outlined,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                appName,
                                style: textTheme.displaySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Secure VPN Connection',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      XBInputField(
                        controller: _emailController,
                        labelText: appLocalizations.xboardEmail,
                        hintText: appLocalizations.xboardEmail,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations.xboardEmail;
                          }
                          if (!value.contains('@')) {
                            return appLocalizations.xboardEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      XBInputField(
                        controller: _passwordController,
                        labelText: appLocalizations.xboardPassword,
                        hintText: appLocalizations.xboardPassword,
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
                            return appLocalizations.xboardPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberPassword,
                              onChanged: (value) {
                                setState(() {
                                  _rememberPassword = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberPassword = !_rememberPassword;
                              });
                            },
                            child: Text(
                              appLocalizations.xboardRememberPassword,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: !userState.isLoading ? _login : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xff0369A1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: userState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    appLocalizations.xboardLogin,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _navigateToForgotPassword,
                            child: Text(
                              appLocalizations.xboardForgotPassword,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            child: Text(
                              appLocalizations.xboardRegister,
                            ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    /// 构建初始化状态指示器
    Widget _buildInitializationIndicator(InitializationState initState) {
      Color statusColor;
      IconData statusIcon;
      
      switch (initState.status) {
        case InitializationStatus.checkingDomain:
        case InitializationStatus.initializingSDK:
          statusColor = Colors.orange;
          statusIcon = Icons.sync;
          break;
        case InitializationStatus.ready:
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          break;
        case InitializationStatus.failed:
          statusColor = Colors.red;
          statusIcon = Icons.error;
          break;
        case InitializationStatus.idle:
          statusColor = Colors.grey;
          statusIcon = Icons.dns;
          break;
      }
      
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          initState.isInitializing
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                )
              : Icon(
                  statusIcon,
                  size: 12,
                  color: statusColor,
                ),
        ],
      );
    }
  }