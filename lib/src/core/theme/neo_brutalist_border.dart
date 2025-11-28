import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class NeoBrutalistBorder extends RoundedRectangleBorder {
  // Fields for custom shadow properties
  final Color shadowColor;
  final Offset shadowOffset;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;

  const NeoBrutalistBorder({
    super.side = BorderSide.none,
    super.borderRadius = BorderRadius.zero,
    this.shadowColor = Colors.black, // Default values for these fields
    this.shadowOffset = Offset.zero,
    this.shadowBlurRadius = 0.0,
    this.shadowSpreadRadius = 0.0,
  });

  @override
  Path getInnerPath(ui.Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width));
  }

  @override
  Path getOuterPath(ui.Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, ui.Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return;

    final RRect outer = borderRadius.resolve(textDirection).toRRect(rect);
    final RRect inner = outer.deflate(side.width);

    // Draw the hard offset shadow first
    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = shadowBlurRadius > 0
          ? ui.MaskFilter.blur(ui.BlurStyle.normal, shadowBlurRadius)
          : null;

    canvas.drawPath(
      Path()
        ..addRRect(outer.shift(shadowOffset).inflate(shadowSpreadRadius)),
      paint,
    );

    // Then draw the border itself
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRRect(outer),
        Path()..addRRect(inner),
      ),
      side.toPaint(),
    );
  }

  @override
  NeoBrutalistBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    Color? shadowColor,
    Offset? shadowOffset,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
  }) {
    return NeoBrutalistBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius ?? this.shadowSpreadRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is NeoBrutalistBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.shadowColor == shadowColor &&
        other.shadowOffset == shadowOffset &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.shadowSpreadRadius == shadowSpreadRadius;
  }

  @override
  int get hashCode => Object.hash(
        side,
        borderRadius,
        shadowColor,
        shadowOffset,
        shadowBlurRadius,
        shadowSpreadRadius,
      );
}