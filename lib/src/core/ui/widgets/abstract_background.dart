import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AbstractBackground extends StatefulWidget {
  final Widget child;

  const AbstractBackground({super.key, required this.child});

  @override
  State<AbstractBackground> createState() => _AbstractBackgroundState();
}

class _AbstractBackgroundState extends State<AbstractBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Blob 1 configuration
  final _blob1Align = Alignment.topLeft;
  final _blob1Color = const Color(0xFF7F00FF); // Purple

  // Blob 2 configuration
  final _blob2Align = Alignment.bottomRight;
  final _blob2Color = const Color(0xFFFF0080); // Magenta

  // Blob 3 configuration
  final _blob3Align = Alignment.topRight;
  final _blob3Color = const Color(0xFF00FFFF); // Cyan

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep background
        Container(color: const Color(0xFF0A0A1E)), // Deep Blue/Black

        // Animated Blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                _buildBlob(
                  alignment: _blob1Align,
                  color: _blob1Color,
                  offset: Offset(
                    50 * cos(_controller.value * 2 * pi), 
                    50 * sin(_controller.value * 2 * pi),
                  ),
                ),
                _buildBlob(
                  alignment: _blob2Align,
                  color: _blob2Color,
                  offset: Offset(
                    -50 * sin(_controller.value * 2 * pi), 
                    -50 * cos(_controller.value * 2 * pi),
                  ),
                ),
                _buildBlob(
                  alignment: _blob3Align,
                  color: _blob3Color,
                  offset: Offset(
                    30 * sin(_controller.value * 2 * pi), 
                    50 * cos(_controller.value * 2 * pi),
                  ),
                ),
                // Add a center blob for warmth
                _buildBlob(
                  alignment: Alignment.center,
                  color: const Color(0xFFFFD700).withAlpha(77),
                  size: 400,
                  offset: Offset(
                    20 * cos(_controller.value * pi),
                    20 * sin(_controller.value * pi),
                  ),
                ),
              ],
            );
          },
        ),

        // Heavy Blur Mesh
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(
            color: Colors.black.withAlpha(25), // Slight tint
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }

  Widget _buildBlob({
    required Alignment alignment,
    required Color color,
    Offset offset = Offset.zero,
    double size = 300,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(153),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(102),
                blurRadius: 100,
                spreadRadius: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
