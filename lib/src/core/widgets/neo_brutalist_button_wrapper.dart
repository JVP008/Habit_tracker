import 'package:flutter/material.dart';

/// A wrapper that converts any ElevatedButton into a NeoBrutalist 3D button
/// This can be used in the app's builder to automatically apply the effect to all buttons
class NeoBrutalistButtonWrapper extends StatefulWidget {
  final Widget child;

  const NeoBrutalistButtonWrapper({super.key, required this.child});

  @override
  State<NeoBrutalistButtonWrapper> createState() =>
      _NeoBrutalistButtonWrapperState();
}

class _NeoBrutalistButtonWrapperState extends State<NeoBrutalistButtonWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Check if the child is an ElevatedButton
    if (widget.child is ElevatedButton) {
      final button = widget.child as ElevatedButton;

      final double currentShadowOffset = _isPressed ? 2.0 : 6.0;
      final double translateY = _isPressed ? 4.0 : 0.0;

      return GestureDetector(
        onTapDown: button.onPressed != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: button.onPressed != null
            ? (_) {
                setState(() => _isPressed = false);
                if (button.onPressed != null) {
                  button.onPressed!();
                }
              }
            : null,
        onTapCancel: button.onPressed != null
            ? () => setState(() => _isPressed = false)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0, translateY, 0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
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

    // If not an ElevatedButton, return as is
    return widget.child;
  }
}
