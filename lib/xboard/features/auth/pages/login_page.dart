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
import 'package:fl_clash/xboard/core/core.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_alert.dart';

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

  // Alert state for inline notifications
  AuthAlertType? _alertType;
  String? _alertMessage;

  @override
  void initState() {
    super.initState();
    _storageService = ref.read(storageServiceProvider);
    _loadSavedCredentials();
    _initializeXBoard();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeXBoard() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(initializationProvider.notifier).initialize();
      } catch (e) {
        // Initialization failure shown via UI state
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
      if (savedPassword != null &&
          savedPassword.isNotEmpty &&
          rememberPassword) {
        _passwordController.text = savedPassword;
      }
      _rememberPassword = rememberPassword;
      if (mounted) setState(() {});
    } catch (e) {
      // Ignore credential loading failure
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final initState = ref.read(initializationProvider);
      if (!initState.isReady) {
        try {
          await ref.read(initializationProvider.notifier).refresh();
        } catch (e) {
          if (mounted) {
            XBoardNotification.showError(
                '${appLocalizations.xboardLoginFailed}: ${ErrorSanitizer.sanitize(e.toString())}');
          }
          return;
        }
        final updatedState = ref.read(initializationProvider);
        if (!updatedState.isReady) {
          if (mounted) {
            XBoardNotification.showError(
                updatedState.errorMessage ?? appLocalizations.xboardLoginFailed);
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
                _emailController.text, _passwordController.text, true);
          } else {
            await _storageService.saveCredentials(
                _emailController.text, '', false);
          }
          if (mounted) {
            setState(() {
              _alertType = AuthAlertType.success;
              _alertMessage = appLocalizations.xboardLoginSuccess;
            });
            XBoardNotification.showSuccess(appLocalizations.xboardLoginSuccess);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) context.go('/');
            });
          }
        } else {
          final userState = ref.read(xboardUserProvider);
          if (userState.errorMessage != null) {
            setState(() {
              _alertType = AuthAlertType.error;
              _alertMessage = userState.errorMessage;
            });
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
    _initializeXBoard();
  }

  void _navigateToForgotPassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
    _initializeXBoard();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initState = ref.watch(initializationProvider);
    final userState = ref.watch(xboardUserProvider);

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language selector + initialization indicator (top-right)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildInitializationIndicator(initState),
                const SizedBox(width: 8),
                const LanguageSelector(),
              ],
            ),
            const SizedBox(height: 16),

            // Header: centered title + subtitle
            Text(
              appLocalizations.xboardLogin,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appName,
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

            // Email field
            XBInputField(
              controller: _emailController,
              labelText: appLocalizations.xboardEmail,
              hintText: appLocalizations.xboardEmail,
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

            // Password field with "Forgot Password?" in label row
            XBInputField(
              controller: _passwordController,
              labelText: appLocalizations.xboardPassword,
              hintText: appLocalizations.xboardPassword,
              obscureText: !_isPasswordVisible,
              labelTrailing: GestureDetector(
                onTap: _navigateToForgotPassword,
                child: Text(
                  appLocalizations.xboardForgotPassword,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
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

            // Remember me checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberPassword = !_rememberPassword;
                });
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          _rememberPassword = value ?? false;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appLocalizations.xboardRememberPassword,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Login button (matching: w-full bg-primary-600 rounded-lg)
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: !userState.isLoading ? _login : null,
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
                child: userState.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        appLocalizations.xboardLogin,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer: "Don't have account? Register"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${appLocalizations.noAccount} ',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: _navigateToRegister,
                  child: Text(
                    appLocalizations.xboardRegister,
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

  Widget _buildInitializationIndicator(InitializationState initState) {
    final colorScheme = Theme.of(context).colorScheme;
    Color statusColor;
    IconData statusIcon;

    switch (initState.status) {
      case InitializationStatus.checkingDomain:
      case InitializationStatus.initializingSDK:
        statusColor = colorScheme.secondary;
        statusIcon = Icons.sync;
        break;
      case InitializationStatus.ready:
        statusColor = colorScheme.tertiary;
        statusIcon = Icons.check_circle;
        break;
      case InitializationStatus.failed:
        statusColor = colorScheme.error;
        statusIcon = Icons.error;
        break;
      case InitializationStatus.idle:
        statusColor = colorScheme.outline;
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
            : Icon(statusIcon, size: 12, color: statusColor),
      ],
    );
  }
}
