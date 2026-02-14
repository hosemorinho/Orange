import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/initialization/initialization.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Simplified login page optimized for Android TV D-pad navigation.
class TvLoginPage extends ConsumerStatefulWidget {
  const TvLoginPage({super.key});

  @override
  ConsumerState<TvLoginPage> createState() => _TvLoginPageState();
}

class _TvLoginPageState extends ConsumerState<TvLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _loginButtonFocus = FocusNode();

  String? _errorMessage;
  late XBoardStorageService _storageService;

  @override
  void initState() {
    super.initState();
    _storageService = ref.read(storageServiceProvider);
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _loginButtonFocus.dispose();
    super.dispose();
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
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final initState = ref.read(initializationProvider);
    if (!initState.isReady) {
      try {
        await ref.read(initializationProvider.notifier).refresh();
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = ErrorSanitizer.sanitize(e.toString());
          });
        }
        return;
      }
      final updatedState = ref.read(initializationProvider);
      if (!updatedState.isReady) {
        if (mounted) {
          setState(() {
            _errorMessage =
                updatedState.errorMessage ?? appLocalizations.xboardLoginFailed;
          });
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
        await _storageService.saveCredentials(
          _emailController.text,
          _passwordController.text,
          true,
        );
        if (mounted) {
          XBoardNotification.showSuccess(appLocalizations.xboardLoginSuccess);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) context.go('/');
          });
        }
      } else {
        final userState = ref.read(xboardUserProvider);
        setState(() {
          _errorMessage = userState.errorMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userState = ref.watch(xboardUserProvider);
    final initState = ref.watch(initializationProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vpn_key, size: 64, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (initState.isInitializing)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  appLocalizations.xboardInitializing,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Error banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Email field
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: _TvTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: appLocalizations.xboardEmail,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.pleaseEnterEmail;
                        }
                        if (!value.contains('@')) {
                          return appLocalizations.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: _TvTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: appLocalizations.xboardPassword,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.pleaseEnterPassword;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: _TvFocusButton(
                      focusNode: _loginButtonFocus,
                      onPressed:
                          !userState.isLoading && !initState.isInitializing
                          ? _login
                          : null,
                      isLoading: userState.isLoading,
                      label: appLocalizations.xboardLogin,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TvTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _TvTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }
}

class _TvFocusButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _TvFocusButton({
    required this.focusNode,
    required this.onPressed,
    required this.isLoading,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  State<_TvFocusButton> createState() => _TvFocusButtonState();
}

class _TvFocusButtonState extends State<_TvFocusButton> {
  bool _isFocused = false;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
      widget.onPressed?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64,
          decoration: BoxDecoration(
            color: widget.onPressed != null
                ? widget.colorScheme.primary
                : widget.colorScheme.primary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: _isFocused
                ? Border.all(color: widget.colorScheme.onSurface, width: 3)
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: widget.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    widget.label,
                    style: widget.textTheme.titleMedium?.copyWith(
                      color: widget.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
