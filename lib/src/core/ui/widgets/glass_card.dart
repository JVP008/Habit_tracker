import 'package:flutter/material.dart';

import 'package:habit_tracker/src/core/ui/widgets/glass_container.dart'; // Explicitly import GlassContainer

/// A card widget with glass morphism effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blurStrength;
  final double opacity;
  final Gradient? gradient;
  final Gradient? borderGradient;
  final double borderWidth;
  final Color? borderColor;
  final Color shadowColor;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final Offset shadowOffset;
  final bool enableGlassEffect;
  final Color? backgroundColor;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final BoxShape shape;
  final VoidCallback? onTap;
  final BorderRadius? customBorderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.blurStrength = 10.0,
    this.opacity = 0.2,
    this.gradient,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.borderColor,
    this.shadowColor = Colors.black12,
    this.shadowBlurRadius = 8.0,
    this.shadowSpreadRadius = 0.0,
    this.shadowOffset = Offset.zero,
    this.enableGlassEffect = true,
    this.backgroundColor,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.shape = BoxShape.rectangle,
    this.onTap,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor =
        backgroundColor ?? (isDarkMode ? Colors.black38 : Colors.white38);

    final effectiveBorderColor =
        borderColor ?? (isDarkMode ? Colors.white12 : Colors.black12);

    final effectiveGradient =
        gradient ??
        LinearGradient(
          colors: [
            effectiveBackgroundColor.withValues(alpha: 0.8),
            effectiveBackgroundColor.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius:
            customBorderRadius ??
            (shape == BoxShape.rectangle
                ? BorderRadius.circular(borderRadius)
                : null),
        shape: shape,
        border: Border.all(color: effectiveBorderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: enableGlassEffect ? null : effectiveGradient,
          borderRadius:
              customBorderRadius ??
              (shape == BoxShape.rectangle
                  ? BorderRadius.circular(borderRadius)
                  : null),
          shape: shape,
        ),
        child: enableGlassEffect
            ? GlassContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius:
                    customBorderRadius ??
                    (shape == BoxShape.rectangle
                        ? BorderRadius.circular(borderRadius)
                        : BorderRadius.zero),
                gradient: effectiveGradient,
                borderGradient: borderGradient,
                borderWidth: borderGradient != null ? borderWidth : 0.0,
                borderColor: borderGradient == null
                    ? effectiveBorderColor
                    : null,
                elevation: elevation,
                isFrostedGlass: true,
                shadowColor: shadowColor,
                blur: blurStrength,
                color: effectiveBackgroundColor.withValues(alpha: 0.1),
                child: child,
              )
            : child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }

  // Factory constructor for a primary card
  factory GlassCard.primary({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius ?? 16.0,
      elevation: elevation ?? 4.0,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.8),
          theme.colorScheme.primary.withValues(alpha: 0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.8),
          theme.colorScheme.secondary.withValues(alpha: 0.8),
        ],
      ),
      borderWidth: 1.0,
      onTap: onTap,
      child: child,
    );
  }

  // Factory constructor for a secondary card
  factory GlassCard.secondary({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius ?? 16.0,
      elevation: elevation ?? 2.0,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.secondaryContainer.withValues(alpha: 0.8),
          theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.5),
      borderWidth: 1.0,
      onTap: onTap,
      child: child,
    );
  }

  // Factory constructor for an outlined card
  factory GlassCard.outlined({
    required BuildContext context,
    required Widget child,
    Color? borderColor,
    double? borderWidth,
    double? width,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius ?? 16.0,
      elevation: elevation ?? 1.0,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      backgroundColor: Colors.transparent,
      borderColor: borderColor ?? theme.dividerColor,
      borderWidth: borderWidth ?? 1.0,
      enableGlassEffect: false,
      onTap: onTap,
      child: child,
    );
  }
}

// Extension to create glass cards directly from theme
extension GlassCardThemeExtension on ThemeData {
  GlassCard glassCard({
    required Widget child,
    double width = double.infinity,
    double? height,
    double borderRadius = 16.0,
    double elevation = 4.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    EdgeInsetsGeometry? margin,
    double blurStrength = 10.0,
    double opacity = 0.2,
    Gradient? gradient,
    Gradient? borderGradient,
    double borderWidth = 1.0,
    Color? borderColor,
    Color? shadowColor,
    double shadowBlurRadius = 8.0,
    double shadowSpreadRadius = 0.0,
    Offset shadowOffset = Offset.zero,
    bool enableGlassEffect = true,
    Color? backgroundColor,
    BoxConstraints? constraints,
    Clip clipBehavior = Clip.antiAlias,
    BoxShape shape = BoxShape.rectangle,
    VoidCallback? onTap,
    BorderRadius? customBorderRadius,
  }) {
    return GlassCard(
      width: width,
      height: height ?? double.infinity,
      borderRadius: borderRadius,
      elevation: elevation,
      padding: padding,
      margin: margin,
      blurStrength: blurStrength,
      opacity: opacity,
      gradient: gradient,
      borderGradient: borderGradient,
      borderWidth: borderWidth,
      borderColor: borderColor,
      shadowColor: shadowColor ?? Colors.black12,
      shadowBlurRadius: shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius,
      shadowOffset: shadowOffset,
      enableGlassEffect: enableGlassEffect,
      backgroundColor: backgroundColor,
      constraints: constraints,
      clipBehavior: clipBehavior,
      shape: shape,
      onTap: onTap,
      customBorderRadius: customBorderRadius,
      child: child,
    );
  }
}
