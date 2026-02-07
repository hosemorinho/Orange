import 'package:flutter/material.dart';
import 'auth_header.dart';
import 'auth_footer.dart';

/// Shared auth layout matching the frontend's AuthLayout component.
///
/// Provides a gradient background with a centered card container,
/// matching the CSS pattern:
///   bg-gradient-to-br from-primary-50 via-white to-primary-50
///   Card: bg-white rounded-2xl shadow-lg border p-8
///
/// Frontend layout: Column(Header + Expanded(Center(Card)) + Footer)
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? headerTrailing;

  const AuthScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.onBack,
    this.headerTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.15),
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header (matches PageHeader)
            SafeArea(
              bottom: false,
              child: AuthHeader(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerTrailing != null) headerTrailing!,
                    if (showBackButton) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onBack ?? () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Main content (flex-1 centered)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color:
                                colorScheme.shadow.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),

            // Footer (matches PageFooter)
            const SafeArea(
              top: false,
              child: AuthFooter(),
            ),
          ],
        ),
      ),
    );
  }
}
