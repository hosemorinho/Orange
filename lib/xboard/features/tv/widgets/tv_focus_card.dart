import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tv_design_tokens.dart';

/// Base focusable container for all TV interactive elements.
///
/// Provides D-pad focus handling with visual focus/selected states.
class TvFocusCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const TvFocusCard({
    super.key,
    required this.child,
    this.onPressed,
    this.isSelected = false,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
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
    widget.onFocusChange?.call(hasFocus);
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
    final radius =
        widget.borderRadius ??
        BorderRadius.circular(TvDesignTokens.controlRadius);

    Color bgColor = colorScheme.surfaceContainerLow.withValues(alpha: 0.34);
    Border border = Border.all(
      color: colorScheme.outlineVariant.withValues(alpha: 0.28),
      width: 1,
    );
    List<BoxShadow> shadow = const [];

    if (widget.isSelected) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.52);
      border = Border.all(
        color: colorScheme.primary.withValues(alpha: 0.42),
        width: 1.2,
      );
    }

    if (_isFocused) {
      bgColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.92);
      border = Border.all(color: colorScheme.primary, width: 2.4);
      shadow = [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.28),
          blurRadius: 20,
          spreadRadius: 0.4,
        ),
      ];
    }

    if (_isFocused && widget.isSelected) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.9);
      border = Border.all(color: colorScheme.primary, width: 2.6);
      shadow = [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.34),
          blurRadius: 24,
          spreadRadius: 0.8,
        ),
      ];
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onFocusChange: _handleFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: TvDesignTokens.focusDuration,
          curve: Curves.easeOutCubic,
          scale: _isFocused ? 1.02 : 1,
          child: AnimatedContainer(
            duration: TvDesignTokens.focusDuration,
            curve: Curves.easeOutCubic,
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              border: border,
              boxShadow: shadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
