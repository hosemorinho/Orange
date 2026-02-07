import 'package:flutter/material.dart';

enum AuthAlertType { success, error, warning, info }

/// Inline alert matching frontend's Alert component.
///
/// CSS: border rounded-lg p-4 flex items-start gap-3
/// Types: success (green), error (red), warning (amber), info (blue)
class AuthAlert extends StatelessWidget {
  final AuthAlertType type;
  final String message;
  final VoidCallback? onClose;

  const AuthAlert({
    super.key,
    this.type = AuthAlertType.info,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, iconColor, icon) = _getStyleForType(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // p-4
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8), // rounded-lg
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon (flex-shrink-0)
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12), // gap-3
          // Message (flex-1 text-sm font-medium)
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          // Close button
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Opacity(
                opacity: 0.7,
                child: Icon(Icons.close, size: 16, color: iconColor),
              ),
            ),
        ],
      ),
    );
  }

  (Color, Color, Color, IconData) _getStyleForType(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (type) {
      AuthAlertType.success => (
          const Color(0xFF10b981).withValues(alpha: 0.1), // bg-success/10
          const Color(0xFF10b981), // border-success
          const Color(0xFF10b981), // text-success
          Icons.check_circle,
        ),
      AuthAlertType.error => (
          colorScheme.error.withValues(alpha: 0.1),
          colorScheme.error,
          colorScheme.error,
          Icons.cancel,
        ),
      AuthAlertType.warning => (
          const Color(0xFFf59e0b).withValues(alpha: 0.1),
          const Color(0xFFf59e0b),
          const Color(0xFFf59e0b),
          Icons.warning_rounded,
        ),
      AuthAlertType.info => (
          const Color(0xFF3b82f6).withValues(alpha: 0.1),
          const Color(0xFF3b82f6),
          const Color(0xFF3b82f6),
          Icons.info,
        ),
    };
  }
}
