import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_alert.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _codeSent = false;
  bool _isSuccess = false;
  bool _obscurePassword = true;
  int _countdown = 0;

  // Alert state for inline notifications
  AuthAlertType? _alertType;
  String? _alertMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    // Validate email only
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      XBoardNotification.showError(
          AppLocalizations.of(context).pleaseEnterEmail);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      XBoardNotification.showError(
          AppLocalizations.of(context).pleaseEnterValidEmail);
      return;
    }

    setState(() => _isSendingCode = true);
    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.sendEmailVerify(_emailController.text);
      if (mounted) {
        setState(() => _codeSent = true);
        XBoardNotification.showSuccess(
            AppLocalizations.of(context).verificationCodeSent);
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        XBoardNotification.showError(
            '${AppLocalizations.of(context).sendCodeFailed}: ${ErrorSanitizer.sanitize(e.toString())}');
      }
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_codeSent) {
      XBoardNotification.showError(
          AppLocalizations.of(context).sendVerificationCode);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.forget(
        _emailController.text,
        _codeController.text,
        _passwordController.text,
      );
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _alertType = AuthAlertType.success;
          _alertMessage =
              AppLocalizations.of(context).passwordResetSuccessful;
        });
        XBoardNotification.showSuccess(
            AppLocalizations.of(context).passwordResetSuccessful);
      }
    } catch (e) {
      if (mounted) {
        final sanitized = ErrorSanitizer.sanitize(e.toString());
        setState(() {
          _alertType = AuthAlertType.error;
          _alertMessage =
              '${AppLocalizations.of(context).passwordResetFailed}: $sanitized';
        });
        XBoardNotification.showError(
            '${AppLocalizations.of(context).passwordResetFailed}: $sanitized');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      showBackButton: true,
      onBack: () => context.pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: key icon + title + subtitle (matching frontend)
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.vpn_key_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).resetPassword,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).enterEmailForReset,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Alert notification (matching frontend inline alert)
          if (_alertMessage != null && !_isSuccess) ...[
            AuthAlert(
              type: _alertType!,
              message: _alertMessage!,
              onClose: () => setState(() => _alertMessage = null),
            ),
            const SizedBox(height: 24),
          ],

          // Success state (matching frontend)
          if (_isSuccess) ...[
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  // Frontend uses bg-success/10 (green), not tertiary (pink-purple)
                  color: const Color(0xFF10b981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 32,
                  color: Color(0xFF10b981), // success green
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).passwordResetSuccessful,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _emailController.text,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).backToLogin,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
          ] else ...[
            // Form: single page (matching frontend ForgotPasswordForm)
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email
                  XBInputField(
                    controller: _emailController,
                    labelText: AppLocalizations.of(context).emailAddress,
                    hintText: AppLocalizations.of(context).pleaseEnterEmail,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).pleaseEnterEmail;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return AppLocalizations.of(context)
                            .pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // New Password
                  XBInputField(
                    controller: _passwordController,
                    labelText: AppLocalizations.of(context).newPassword,
                    hintText:
                        AppLocalizations.of(context).pleaseEnterNewPassword,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(
                            () => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)
                            .pleaseEnterNewPassword;
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context).passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email code + send button (matching frontend inline pattern)
                  _buildEmailCodeField(context, colorScheme, textTheme),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: !_isLoading ? _resetPassword : null,
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
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).resetPassword,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Footer: "Back to Login"
            Center(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  AppLocalizations.of(context).backToLogin,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Email code field with inline send/resend button
  /// Matching frontend pattern: flex gap-2, input flex-1 + Button variant=outline
  Widget _buildEmailCodeField(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).verificationCode,
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
                controller: _codeController,
                keyboardType: TextInputType.number,
                enabled: _codeSent && !_isLoading,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .pleaseEnterVerificationCode,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: (_codeSent && !_isLoading)
                      ? colorScheme.surface
                      : colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
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
                  if (!_codeSent) {
                    return AppLocalizations.of(context).sendVerificationCode;
                  }
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)
                        .pleaseEnterVerificationCode;
                  }
                  if (value.length < 4) {
                    return AppLocalizations.of(context)
                        .pleaseEnterValidVerificationCode;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            // Send/Resend code button (matching: Button variant=outline)
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: (_countdown > 0 || _isSendingCode)
                    ? null
                    : _sendVerificationCode,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSendingCode
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
                            : _codeSent
                                ? AppLocalizations.of(context)
                                    .resendVerificationCode
                                : AppLocalizations.of(context)
                                    .sendVerificationCode,
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
