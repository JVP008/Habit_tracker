import 'package:flutter/material.dart';

/// A 3D neobrutalist-style button with push-down animation effect
class NeoBrutalistButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final double shadowOffset;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const NeoBrutalistButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderWidth = 4.0,
    this.borderRadius = 12.0,
    this.shadowOffset = 6.0,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.shadowColor = Colors.black,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<NeoBrutalistButton> createState() => _NeoBrutalistButtonState();
}

class _NeoBrutalistButtonState extends State<NeoBrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentShadowOffset = _isPressed ? 2.0 : widget.shadowOffset;
    final double translateY = _isPressed ? widget.shadowOffset - 2.0 : 0.0;

    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: widget.onPressed != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(0, translateY, 0),
        child: Container(
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(0, currentShadowOffset),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
