import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:habit_tracker/src/core/ui/widgets/glass_container.dart';

/// A customizable app bar with glass morphism effect
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The primary widget displayed in the app bar
  final Widget? title;

  /// The widget to display before the title
  final Widget? leading;

  /// The widgets to display after the title
  final List<Widget>? actions;

  /// The height of the app bar
  final double height;

  /// The elevation of the app bar
  final double elevation;

  /// The blur strength of the glass effect
  final double blurStrength;

  /// The opacity of the glass effect
  final double opacity;

  /// The gradient to use for the glass effect
  final Gradient? gradient;

  /// The border gradient to use for the glass effect
  final Gradient? borderGradient;

  /// The border width of the app bar
  final double borderWidth;

  /// The border color of the app bar
  final Color? borderColor;

  /// The background color of the app bar
  final Color? backgroundColor;

  /// The padding around the title and actions
  final EdgeInsetsGeometry? padding;

  /// Whether to automatically adjust the app bar's elevation based on scroll
  final bool automaticallyImplyLeading;

  /// The spacing around the title content on the horizontal axis
  final double? titleSpacing;

  /// The font size of the title text
  final double? titleFontSize;

  /// The font weight of the title text
  final FontWeight? titleFontWeight;

  /// The color of the title text
  final Color? titleTextColor;

  /// The text style of the title
  final TextStyle? titleTextStyle;

  /// Whether to show the shadow below the app bar
  final bool showShadow;

  /// The color of the shadow
  final Color shadowColor;

  /// The blur radius of the shadow
  final double shadowBlurRadius;

  /// The spread radius of the shadow
  final double shadowSpreadRadius;

  /// The offset of the shadow
  final Offset shadowOffset;

  /// The shape of the app bar's bottom
  final PreferredSizeWidget? bottom;

  /// The height of the bottom widget
  final double? bottomHeight;

  /// The border radius of the app bar
  final BorderRadius? borderRadius;

  /// Whether to use the system UI overlay style
  final bool useSystemUIOverlayStyle;

  /// The brightness of the system UI overlay style
  final Brightness? systemOverlayStyle;

  /// The status bar color
  final Color? statusBarColor;

  /// Whether to force material transparency
  final bool forceMaterialTransparency;

  /// The toolbar height
  final double? toolbarHeight;

  /// The leading width
  final double? leadingWidth;

  /// Whether to center the title
  final bool? centerTitle;

  /// The shape of the app bar
  final ShapeBorder? shape;

  /// The elevation of the shadow
  final double? shadowElevation;

  /// The scrolled under elevation
  final double? scrolledUnderElevation;

  /// The surface tint color
  final Color? surfaceTintColor;

  /// The shadow color of the app bar
  final Color? appBarShadowColor;

  /// The color of the app bar's material
  final Color? appBarMaterialColor;

  /// The gradient to use for the app bar's background
  final Gradient? appBarGradient;

  /// The callback when the user taps the app bar
  final GestureTapCallback? onTap;

  /// The callback when the user double taps the app bar
  final GestureTapCallback? onDoubleTap;

  /// The callback when the user long presses the app bar
  final GestureLongPressCallback? onLongPress;

  /// The callback when the user hovers over the app bar
  final ValueChanged<bool>? onHover;

  /// The callback when the pointer enters the app bar
  final void Function(PointerEnterEvent)? onEnter;

  /// The callback when the pointer exits the app bar
  final void Function(PointerExitEvent)? onExit;

  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.height = kToolbarHeight,
    this.elevation = 0.0,
    this.blurStrength = 10.0,
    this.opacity = 0.2,
    this.gradient,
    this.borderGradient,
    this.borderWidth = 0.0,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.titleFontSize,
    this.titleFontWeight,
    this.titleTextColor,
    this.titleTextStyle,
    this.showShadow = true,
    this.shadowColor = Colors.black12,
    this.shadowBlurRadius = 8.0,
    this.shadowSpreadRadius = 0.0,
    this.shadowOffset = Offset.zero,
    this.bottom,
    this.bottomHeight,
    this.borderRadius,
    this.useSystemUIOverlayStyle = true,
    this.systemOverlayStyle,
    this.statusBarColor,
    this.forceMaterialTransparency = false,
    this.toolbarHeight,
    this.leadingWidth,
    this.centerTitle,
    this.shape,
    this.shadowElevation,
    this.scrolledUnderElevation,
    this.surfaceTintColor,
    this.appBarShadowColor,
    this.appBarMaterialColor,
    this.appBarGradient,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
    this.onEnter,
    this.onExit,
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

    final appBar = AppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      titleTextStyle:
          titleTextStyle ??
          theme.textTheme.titleLarge?.copyWith(
            color: titleTextColor ?? theme.colorScheme.onSurface,
            fontSize: titleFontSize,
            fontWeight: titleFontWeight ?? FontWeight.w600,
          ),
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight ?? height,
      leadingWidth: leadingWidth,
      shape: shape,
      shadowColor: appBarShadowColor,
      surfaceTintColor: surfaceTintColor,
      foregroundColor: titleTextColor ?? theme.colorScheme.onSurface,
      iconTheme: IconThemeData(
        color: titleTextColor ?? theme.colorScheme.onSurface,
      ),
      actionsIconTheme: IconThemeData(
        color: titleTextColor ?? theme.colorScheme.onSurface,
      ),
      bottom: bottom,
      scrolledUnderElevation: scrolledUnderElevation,
    );

    Widget glassAppBar = GlassContainer(
      height: height + (bottom?.preferredSize.height ?? 0.0),
      width: double.infinity,
      gradient: effectiveGradient,
      borderGradient: borderGradient,
      borderWidth: borderGradient != null ? borderWidth : 0.0,
      borderColor: borderGradient == null ? effectiveBorderColor : null,
      borderRadius: borderRadius ?? BorderRadius.zero,
      blur: blurStrength,
      color: effectiveBackgroundColor.withValues(alpha: opacity),
      elevation: elevation,
      shadowColor: shadowColor,
      child: Material(color: Colors.transparent, child: appBar),
    );

    if (showShadow) {
      glassAppBar = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: shadowBlurRadius,
              spreadRadius: shadowSpreadRadius,
              offset: shadowOffset,
            ),
          ],
        ),
        child: glassAppBar,
      );
    }

    if (onTap != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onHover != null ||
        onEnter != null ||
        onExit != null) {
      glassAppBar = MouseRegion(
        onEnter: onEnter,
        onExit: onExit,
        onHover: (event) => onHover?.call(true),
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: glassAppBar,
        ),
      );
    }

    return glassAppBar;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0));

  /// Creates a primary app bar with the app's primary color
  factory GlassAppBar.primary({
    required BuildContext context,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    double? height,
    double? elevation,
    double? blurStrength,
    double? opacity,
    Gradient? gradient,
    Gradient? borderGradient,
    double? borderWidth,
    Color? borderColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    bool? automaticallyImplyLeading,
    double? titleSpacing,
    double? titleFontSize,
    FontWeight? titleFontWeight,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    bool? showShadow,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    Offset? shadowOffset,
    PreferredSizeWidget? bottom,
    double? bottomHeight,
    BorderRadius? borderRadius,
    bool? useSystemUIOverlayStyle,
    Brightness? systemOverlayStyle,
    Color? statusBarColor,
    bool? forceMaterialTransparency,
    double? toolbarHeight,
    double? leadingWidth,
    bool? centerTitle,
    ShapeBorder? shape,
    double? shadowElevation,
    double? scrolledUnderElevation,
    Color? surfaceTintColor,
    Color? appBarShadowColor,
    Color? appBarMaterialColor,
    Gradient? appBarGradient,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    void Function(PointerEnterEvent)? onEnter,
    void Function(PointerExitEvent)? onExit,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GlassAppBar(
      title: title,
      leading: leading,
      actions: actions,
      height: height ?? kToolbarHeight,
      elevation: elevation ?? 0.0,
      blurStrength: blurStrength ?? 15.0,
      opacity: opacity ?? 0.3,
      gradient:
          gradient ??
          LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.9),
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      borderGradient:
          borderGradient ??
          LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.colorScheme.secondary.withValues(alpha: 0.8),
            ],
          ),
      borderWidth: borderWidth ?? 0.5,
      borderColor:
          borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.3),
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.2),
      padding: padding,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      titleSpacing: titleSpacing,
      titleFontSize: titleFontSize,
      titleFontWeight: titleFontWeight ?? FontWeight.w600,
      titleTextColor: titleTextColor ?? theme.colorScheme.onPrimary,
      titleTextStyle: titleTextStyle,
      showShadow: showShadow ?? true,
      shadowColor:
          shadowColor ?? theme.colorScheme.shadow.withValues(alpha: 0.1),
      shadowBlurRadius: shadowBlurRadius ?? 10.0,
      shadowSpreadRadius: shadowSpreadRadius ?? 0.0,
      shadowOffset: shadowOffset ?? const Offset(0, 2),
      bottom: bottom,
      bottomHeight: bottomHeight,
      borderRadius: borderRadius,
      useSystemUIOverlayStyle: useSystemUIOverlayStyle ?? true,
      systemOverlayStyle:
          systemOverlayStyle ??
          (isDarkMode ? Brightness.light : Brightness.dark),
      statusBarColor: statusBarColor,
      forceMaterialTransparency: forceMaterialTransparency ?? false,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      centerTitle: centerTitle,
      shape: shape,
      shadowElevation: shadowElevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
      appBarShadowColor: appBarShadowColor,
      appBarMaterialColor: appBarMaterialColor,
      appBarGradient: appBarGradient,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
      onEnter: onEnter,
      onExit: onExit,
    );
  }

  /// Creates a secondary app bar with a more subtle appearance
  factory GlassAppBar.secondary({
    required BuildContext context,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    double? height,
    double? elevation,
    double? blurStrength,
    double? opacity,
    Gradient? gradient,
    Gradient? borderGradient,
    double? borderWidth,
    Color? borderColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    bool? automaticallyImplyLeading,
    double? titleSpacing,
    double? titleFontSize,
    FontWeight? titleFontWeight,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    bool? showShadow,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    Offset? shadowOffset,
    PreferredSizeWidget? bottom,
    double? bottomHeight,
    BorderRadius? borderRadius,
    bool? useSystemUIOverlayStyle,
    Brightness? systemOverlayStyle,
    Color? statusBarColor,
    bool? forceMaterialTransparency,
    double? toolbarHeight,
    double? leadingWidth,
    bool? centerTitle,
    ShapeBorder? shape,
    double? shadowElevation,
    double? scrolledUnderElevation,
    Color? surfaceTintColor,
    Color? appBarShadowColor,
    Color? appBarMaterialColor,
    Gradient? appBarGradient,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
  }) {
    final theme = Theme.of(context);

    return GlassAppBar(
      title: title,
      leading: leading,
      actions: actions,
      height: height ?? kToolbarHeight,
      elevation: elevation ?? 0.0,
      blurStrength: blurStrength ?? 10.0,
      opacity: opacity ?? 0.2,
      gradient:
          gradient ??
          LinearGradient(
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.8),
              theme.colorScheme.surface.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      borderGradient: borderGradient,
      borderWidth: borderWidth ?? 0.5,
      borderColor:
          borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.2),
      backgroundColor:
          backgroundColor ?? theme.colorScheme.surface.withValues(alpha: 0.2),
      padding: padding,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      titleSpacing: titleSpacing,
      titleFontSize: titleFontSize,
      titleFontWeight: titleFontWeight ?? FontWeight.w600,
      titleTextColor: titleTextColor ?? theme.colorScheme.onSurface,
      titleTextStyle: titleTextStyle,
      showShadow: showShadow ?? true,
      shadowColor:
          shadowColor ?? theme.colorScheme.shadow.withValues(alpha: 0.05),
      shadowBlurRadius: shadowBlurRadius ?? 8.0,
      shadowSpreadRadius: shadowSpreadRadius ?? 0.0,
      shadowOffset: shadowOffset ?? const Offset(0, 1),
      bottom: bottom,
      bottomHeight: bottomHeight,
      borderRadius: borderRadius,
      useSystemUIOverlayStyle: useSystemUIOverlayStyle ?? true,
      systemOverlayStyle: systemOverlayStyle,
      statusBarColor: statusBarColor,
      forceMaterialTransparency: forceMaterialTransparency ?? false,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      centerTitle: centerTitle,
      shape: shape,
      shadowElevation: shadowElevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
      appBarShadowColor: appBarShadowColor,
      appBarMaterialColor: appBarMaterialColor,
      appBarGradient: appBarGradient,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
      onEnter: onEnter,
      onExit: onExit,
    );
  }

  /// Creates a transparent app bar with minimal styling
  factory GlassAppBar.transparent({
    required BuildContext context,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    double? height,
    double? blurStrength,
    double? opacity,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    bool? automaticallyImplyLeading,
    double? titleSpacing,
    double? titleFontSize,
    FontWeight? titleFontWeight,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    PreferredSizeWidget? bottom,
    double? bottomHeight,
    BorderRadius? borderRadius,
    bool? useSystemUIOverlayStyle,
    Brightness? systemOverlayStyle,
    Color? statusBarColor,
    double? toolbarHeight,
    double? leadingWidth,
    bool? centerTitle,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    void Function(PointerEnterEvent)? onEnter,
    void Function(PointerExitEvent)? onExit,
  }) {
    final theme = Theme.of(context);

    return GlassAppBar(
      title: title,
      leading: leading,
      actions: actions,
      height: height ?? kToolbarHeight,
      elevation: 0.0,
      blurStrength: blurStrength ?? 5.0,
      opacity: opacity ?? 0.1,
      backgroundColor: backgroundColor ?? Colors.transparent,
      borderWidth: 0.0,
      padding: padding,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      titleSpacing: titleSpacing,
      titleFontSize: titleFontSize,
      titleFontWeight: titleFontWeight ?? FontWeight.w600,
      titleTextColor: titleTextColor ?? theme.colorScheme.onSurface,
      titleTextStyle: titleTextStyle,
      showShadow: false,
      bottom: bottom,
      bottomHeight: bottomHeight,
      borderRadius: borderRadius,
      useSystemUIOverlayStyle: useSystemUIOverlayStyle ?? true,
      systemOverlayStyle: systemOverlayStyle,
      statusBarColor: statusBarColor,
      forceMaterialTransparency: true,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      centerTitle: centerTitle,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
      onEnter: onEnter,
      onExit: onExit,
    );
  }
}

// Extension to create glass app bars directly from theme
extension GlassAppBarThemeExtension on ThemeData {
  GlassAppBar glassAppBar({
    required BuildContext context,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    double? height,
    double? elevation,
    double? blurStrength,
    double? opacity,
    Gradient? gradient,
    Gradient? borderGradient,
    double? borderWidth,
    Color? borderColor,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    bool? automaticallyImplyLeading,
    double? titleSpacing,
    double? titleFontSize,
    FontWeight? titleFontWeight,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    bool? showShadow,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    Offset? shadowOffset,
    PreferredSizeWidget? bottom,
    double? bottomHeight,
    BorderRadius? borderRadius,
    bool? useSystemUIOverlayStyle,
    Brightness? systemOverlayStyle,
    Color? statusBarColor,
    bool? forceMaterialTransparency,
    double? toolbarHeight,
    double? leadingWidth,
    bool? centerTitle,
    ShapeBorder? shape,
    double? shadowElevation,
    double? scrolledUnderElevation,
    Color? surfaceTintColor,
    Color? appBarShadowColor,
    Color? appBarMaterialColor,
    Gradient? appBarGradient,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    void Function(PointerEnterEvent)? onEnter,
    void Function(PointerExitEvent)? onExit,
  }) {
    return GlassAppBar(
      title: title,
      leading: leading,
      actions: actions,
      height: height ?? kToolbarHeight,
      elevation: elevation ?? 0.0,
      blurStrength: blurStrength ?? 10.0,
      opacity: opacity ?? 0.2,
      gradient: gradient,
      borderGradient: borderGradient,
      borderWidth: borderWidth ?? 0.0,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      padding: padding,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      titleSpacing: titleSpacing,
      titleFontSize: titleFontSize,
      titleFontWeight: titleFontWeight,
      titleTextColor: titleTextColor,
      titleTextStyle: titleTextStyle,
      showShadow: showShadow ?? true,
      shadowColor: shadowColor ?? Colors.black12,
      shadowBlurRadius: shadowBlurRadius ?? 8.0,
      shadowSpreadRadius: shadowSpreadRadius ?? 0.0,
      shadowOffset: shadowOffset ?? Offset.zero,
      bottom: bottom,
      bottomHeight: bottomHeight,
      borderRadius: borderRadius,
      useSystemUIOverlayStyle: useSystemUIOverlayStyle ?? true,
      systemOverlayStyle: systemOverlayStyle,
      statusBarColor: statusBarColor,
      forceMaterialTransparency: forceMaterialTransparency ?? false,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      centerTitle: centerTitle,
      shape: shape,
      shadowElevation: shadowElevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
      appBarShadowColor: appBarShadowColor,
      appBarMaterialColor: appBarMaterialColor,
      appBarGradient: appBarGradient,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
      onEnter: onEnter,
      onExit: onExit,
    );
  }
}
