import 'package:flutter/material.dart';

/// Extension to easily add 3D neobrutalist shadow effect to any widget
extension NeoBrutalistShadow on Widget {
  /// Wraps this widget with a 3D shadow effect and push animation
  Widget withNeoBrutalistShadow({
    bool animate = true,
    double shadowOffset = 6.0,
    Color shadowColor = Colors.black,
    VoidCallback? onPressed,
  }) {
    if (animate && onPressed != null) {
      return _AnimatedShadowWrapper(
        shadowOffset: shadowOffset,
        shadowColor: shadowColor,
        onPressed: onPressed,
        child: this,
      );
    }

    // Static shadow
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(0, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: this,
    );
  }
}

class _AnimatedShadowWrapper extends StatefulWidget {
  final Widget child;
  final double shadowOffset;
  final Color shadowColor;
  final VoidCallback onPressed;

  const _AnimatedShadowWrapper({
    required this.child,
    required this.shadowOffset,
    required this.shadowColor,
    required this.onPressed,
  });

  @override
  State<_AnimatedShadowWrapper> createState() => _AnimatedShadowWrapperState();
}

class _AnimatedShadowWrapperState extends State<_AnimatedShadowWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentShadowOffset = _isPressed ? 2.0 : widget.shadowOffset;
    final double translateY = _isPressed ? widget.shadowOffset - 2.0 : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, translateY, 0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(0, currentShadowOffset),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
