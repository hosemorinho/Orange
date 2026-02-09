import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Base focusable container for all TV interactive elements.
///
/// Provides D-pad focus handling with visual focus/selected states.
class TvFocusCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const TvFocusCard({
    super.key,
    required this.child,
    this.onPressed,
    this.isSelected = false,
    this.autofocus = false,
    this.focusNode,
    this.padding,
    this.borderRadius,
  });

  @override
  State<TvFocusCard> createState() => _TvFocusCardState();
}

class _TvFocusCardState extends State<TvFocusCard> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
  }

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
    final colorScheme = Theme.of(context).colorScheme;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    Color bgColor;
    Border? border;

    if (_isFocused && widget.isSelected) {
      bgColor = colorScheme.primaryContainer;
      border = Border.all(color: colorScheme.primary, width: 3);
    } else if (_isFocused) {
      bgColor = colorScheme.surfaceContainerHighest;
      border = Border.all(color: colorScheme.primary, width: 3);
    } else if (widget.isSelected) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.5);
      border = Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3), width: 1);
    } else {
      bgColor = Colors.transparent;
      border = null;
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onFocusChange: _handleFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            border: border,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
