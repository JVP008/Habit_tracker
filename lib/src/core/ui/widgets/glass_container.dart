import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart' as glass_kit;

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final BorderRadiusGeometry
  borderRadius; // Changed from double to BorderRadiusGeometry
  final double blur;
  final double opacity;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadiusGeometry? customBorderRadius; // Added customBorderRadius
  final bool borderOnForeground;
  final Border? border;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final bool isFrostedGlass;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? shadowBorderRadius;
  final List<BoxShadow>? customShadow;
  final BoxShape shape;
  final bool isGradientBorder;
  final GradientBorder? gradientBorder;
  final bool isCircular;
  final double circularRadius;

  // Added parameters to fix errors (these were already present, keeping them)
  final double borderWidth;
  final Color? borderColor;
  final Gradient? borderGradient;
  final Color? shadowColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ), // Default value changed
    this.blur = 10.0,
    this.opacity = 0.2,
    this.elevation,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.customBorderRadius, // Added customBorderRadius to constructor
    this.borderOnForeground = true,
    this.border,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.isFrostedGlass = true,
    this.onTap,
    this.onLongPress,
    this.shadowBorderRadius,
    this.customShadow,
    this.shape = BoxShape.rectangle,
    this.isGradientBorder = false,
    this.gradientBorder,
    this.isCircular = false,
    this.circularRadius = 0.0,
    this.borderWidth = 0.0,
    this.borderColor,
    this.borderGradient,
    this.shadowColor,
  });

  // Factory for frosted glass effect
  factory GlassContainer.frostedGlass({
    Key? key,
    required Widget child,
    double width = double.infinity,
    double height = double.infinity,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ),
    double blur = 10.0,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Gradient? gradient,
    Gradient? borderGradient,
    double borderWidth = 0.0,
    Color? borderColor,
    BorderStyle borderStyle = BorderStyle.solid,
    double shadowStrength = 5,
    Color? shadowColor,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return GlassContainer(
      key: key,
      width: width,
      height: height,
      customBorderRadius: borderRadius, // Use customBorderRadius for factory
      blur: blur,
      elevation: elevation,
      padding: padding,
      margin: margin,
      gradient: gradient,
      borderGradient: borderGradient,
      borderWidth: borderWidth,
      borderColor: borderColor,
      shadowColor: shadowColor,
      onTap: onTap,
      onLongPress: onLongPress,
      shape: shape,
      isFrostedGlass: true,
      isGradientBorder: borderGradient != null,
      child: child,
    );
  }

  // Factory for clear glass effect
  factory GlassContainer.clearGlass({
    Key? key,
    required Widget child,
    double width = double.infinity,
    double height = double.infinity,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ),
    double blur = 5.0,
    double elevation = 0.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Gradient? gradient,
    Color? borderColor,
    double borderWidth = 0.0,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    BoxShape shape = BoxShape.rectangle,
    double? opacity,
    Color? shadowColor,
  }) {
    return GlassContainer(
      key: key,
      width: width,
      height: height,
      opacity: opacity ?? 0.1,
      shadowColor: shadowColor,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Default gradient if none provided
    final defaultGradient = LinearGradient(
      colors: [
        (color ?? theme.colorScheme.surface).withValues(alpha: opacity),
        (color ?? theme.colorScheme.surface).withValues(alpha: opacity * 0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final effectiveGradient = gradient ?? defaultGradient;

    // Use the borderRadius directly
    final effectiveBorderRadius = borderRadius;

    if (isFrostedGlass) {
      return glass_kit.GlassContainer.frostedGlass(
        width: width,
        height: height,
        borderRadius: (customBorderRadius ?? effectiveBorderRadius).resolve(
          Directionality.of(context),
        ),
        blur: blur,
        elevation: elevation ?? 0,
        padding: padding,
        margin: margin,
        gradient: effectiveGradient,
        borderGradient: isGradientBorder
            ? gradientBorder?.gradient ??
                  LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.5),
                      theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
            : null,
        borderWidth: isGradientBorder
            ? 1.0
            : (borderWidth > 0 ? borderWidth : 0),
        borderColor: borderColor ?? border?.top.color ?? Colors.transparent,
        shadowColor: shadowColor,
        child: child,
      );
    }

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface.withValues(alpha: opacity),
        gradient: effectiveGradient,
        borderRadius: shape == BoxShape.rectangle
            ? effectiveBorderRadius
            : null,
        shape: shape,
        boxShadow:
            customShadow ??
            (elevation != null && elevation! > 0
                ? [
                    BoxShadow(
                      color:
                          shadowColor ??
                          (isDarkMode
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3)),
                      blurRadius: elevation! * 2,
                      offset: Offset(0, elevation! / 2),
                    ),
                  ]
                : null),
        border:
            border ??
            (borderWidth > 0
                ? Border.all(
                    color: borderColor ?? Colors.white.withValues(alpha: 0.2),
                    width: borderWidth,
                  )
                : null),
      ),
      child: child,
    );

    // Add border radius for circular shape if needed
    if (isCircular) {
      container = ClipRRect(
        borderRadius: BorderRadius.circular(
          circularRadius > 0 ? circularRadius : 16.0,
        ),
        child: container,
      );
    }

    // Add gesture detectors if callbacks are provided
    if (onTap != null || onLongPress != null) {
      container = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: effectiveBorderRadius as BorderRadius?,
        child: container,
      );
    }

    return container;
  }

  // Factory constructor for a card with elevation
  factory GlassContainer.elevated({
    required Widget child,
    double width = double.infinity,
    double height = double.infinity,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ),
    double elevation = 4.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Gradient? gradient,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassContainer(
      width: width,
      height: height,
      customShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ],
      child: child,
    );
  }

  // Factory constructor for a button
  factory GlassContainer.button({
    required Widget child,
    required VoidCallback onPressed,
    double width = double.infinity,
    double height = 50.0,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Gradient? gradient,
    bool isFrosted = true,
  }) {
    return GlassContainer(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      padding: EdgeInsets.zero,
      margin: margin,
      color: color,
      gradient: gradient,
      isFrostedGlass: isFrosted,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: width,
            height: height,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A class to define gradient borders
class GradientBorder {
  final Gradient gradient;
  final double width;

  const GradientBorder({required this.gradient, this.width = 1.0});
}

/// Extension to create glass containers with theme colors
extension GlassContainerThemeExtension on ThemeData {
  GlassContainer glassContainer({
    required Widget child,
    double width = double.infinity,
    double height = double.infinity,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(16.0),
    ),
    double blur = 10.0,
    double opacity = 0.2,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Gradient? gradient,
    BorderRadiusGeometry? customBorderRadius,
    bool borderOnForeground = true,
    Border? border,
    BoxConstraints? constraints,
    Clip clipBehavior = Clip.antiAlias,
    bool isFrostedGlass = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    BorderRadius? shadowBorderRadius,
    List<BoxShadow>? customShadow,
    BoxShape shape = BoxShape.rectangle,
    bool isGradientBorder = false,
    GradientBorder? gradientBorder,
    bool isCircular = false,
    double circularRadius = 0.0,
  }) {
    return GlassContainer(
      width: width,
      height: height,
      borderRadius: customBorderRadius ?? borderRadius,
      blur: blur,
      opacity: opacity,
      elevation: elevation,
      padding: padding,
      margin: margin,
      color: color ?? colorScheme.surface,
      gradient: gradient,
      borderOnForeground: borderOnForeground,
      border: border,
      constraints: constraints,
      clipBehavior: clipBehavior,
      isFrostedGlass: isFrostedGlass,
      onTap: onTap,
      onLongPress: onLongPress,
      shadowBorderRadius: shadowBorderRadius,
      customShadow: customShadow,
      shape: shape,
      isGradientBorder: isGradientBorder,
      gradientBorder: gradientBorder,
      isCircular: isCircular,
      circularRadius: circularRadius,
      child: child,
    );
  }
}
