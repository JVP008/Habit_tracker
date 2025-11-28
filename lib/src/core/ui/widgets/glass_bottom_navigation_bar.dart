import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Added for PointerEnterEventListener and PointerExitEventListener
import 'package:flutter/services.dart'; // Added for PointerEnterEventListener
import 'package:habit_tracker/src/core/ui/widgets/glass_container.dart'; // Using custom GlassContainer

typedef PointerEnterEventListener = void Function(PointerEnterEvent event);
typedef PointerExitEventListener = void Function(PointerExitEvent event);

/// A customizable bottom navigation bar with glass morphism effect
class GlassBottomNavigationBar extends StatelessWidget {
  /// The items to display in the bottom navigation bar
  final List<BottomNavigationBarItem> items;

  /// The index of the selected item
  final int currentIndex;

  /// Called when an item is tapped
  final ValueChanged<int> onTap;

  /// The height of the bottom navigation bar
  final double height;

  /// The elevation of the bottom navigation bar
  final double elevation;

  /// The blur strength of the glass effect
  final double blurStrength;

  /// The opacity of the glass effect
  final double opacity;

  /// The gradient to use for the glass effect
  final Gradient? gradient;

  /// The border gradient to use for the glass effect
  final Gradient? borderGradient;

  /// The border width of the bottom navigation bar
  final double borderWidth;

  /// The border color of the bottom navigation bar
  final Color? borderColor;

  /// The background color of the bottom navigation bar
  final Color? backgroundColor;

  /// The padding around the items
  final EdgeInsetsGeometry? padding;

  /// The color of the selected item
  final Color? selectedItemColor;

  /// The color of the unselected items
  final Color? unselectedItemColor;

  /// The icon size of the bottom navigation bar items
  final double? iconSize;

  /// The font size of the selected item label
  final double? selectedFontSize;

  /// The font size of the unselected item labels
  final double? unselectedFontSize;

  /// The font weight of the selected item label
  final FontWeight? selectedFontWeight;

  /// The font weight of the unselected item labels
  final FontWeight? unselectedFontWeight;

  /// Whether to show the selected labels
  final bool? showSelectedLabels;

  /// Whether to show the unselected labels
  final bool? showUnselectedLabels;

  /// The type of the bottom navigation bar
  final BottomNavigationBarType? type;

  /// The shape of the bottom navigation bar
  final NotchedShape? shape;

  /// The color of the selected item background
  final Color? selectedItemBackgroundColor;

  /// The color of the unselected item background
  final Color? unselectedItemBackgroundColor;

  /// The elevation of the selected item
  final double? selectedItemElevation;

  /// The elevation of the unselected items
  final double? unselectedItemElevation;

  /// The margin around the bottom navigation bar
  final EdgeInsetsGeometry? margin;

  /// The border radius of the bottom navigation bar
  final BorderRadius? borderRadius;

  /// The color of the shadow
  final Color? shadowColor;

  /// The blur radius of the shadow
  final double? shadowBlurRadius;

  /// The spread radius of the shadow
  final double? shadowSpreadRadius;

  /// The offset of the shadow
  final Offset? shadowOffset;

  /// Whether to show the shadow
  final bool showShadow;

  /// The curve for the animation when switching between items
  final Curve animationCurve;

  /// The duration of the animation when switching between items
  final Duration animationDuration;

  /// Whether to enable feedback when tapping on items
  final bool enableFeedback;

  /// The material tap target size for the items
  final MaterialTapTargetSize? materialTapTargetSize;

  /// The background color of the navigation bar
  final Color? barBackgroundColor;

  /// The elevation of the navigation bar
  final double? barElevation;

  /// The height of the navigation bar
  final double? barHeight;

  /// The padding of the navigation bar
  final EdgeInsetsGeometry? barPadding;

  /// The width of the navigation bar
  final double? barWidth;

  /// The color of the navigation bar
  final Color? barColor;

  /// The gradient of the navigation bar
  final Gradient? barGradient;

  /// The border radius of the navigation bar
  final BorderRadius? barBorderRadius;

  /// The border width of the navigation bar
  final double? barBorderWidth;

  /// The border color of the navigation bar
  final Color? barBorderColor;

  /// The gradient of the border of the navigation bar
  final Gradient? barBorderGradient;

  /// The blur strength of the navigation bar
  final double? barBlurStrength;

  /// The opacity of the navigation bar
  final double? barOpacity;

  /// The shadow color of the navigation bar
  final Color? barShadowColor;

  /// The blur radius of the shadow of the navigation bar
  final double? barShadowBlurRadius;

  /// The spread radius of the shadow of the navigation bar
  final double? barShadowSpreadRadius;

  /// The offset of the shadow of the navigation bar
  final Offset? barShadowOffset;

  /// Whether to show the shadow of the navigation bar
  final bool? showBarShadow;

  /// The margin of the navigation bar
  final EdgeInsetsGeometry? barMargin;

  /// The padding of the navigation bar
  final EdgeInsetsGeometry? barInnerPadding;

  /// The alignment of the navigation bar
  final Alignment? barAlignment;

  /// The clip behavior of the navigation bar
  final Clip? barClipBehavior;

  /// The semantic container of the navigation bar
  final bool? barSemanticContainer;

  /// The callback when the navigation bar is tapped
  final GestureTapCallback? onBarTap;

  /// The callback when the navigation bar is double tapped
  final GestureTapCallback? onBarDoubleTap;

  /// The callback when the navigation bar is long pressed
  final GestureLongPressCallback? onBarLongPress;

  /// The callback when the pointer enters the navigation bar
  final PointerEnterEventListener? onBarEnter;

  /// The callback when the pointer exits the navigation bar
  final PointerExitEventListener? onBarExit;

  /// The callback when the pointer hovers over the navigation bar
  final ValueChanged<bool>? onBarHover;

  const GlassBottomNavigationBar({
    super.key,
    required this.items,
    required this.onTap,
    required this.currentIndex,
    this.height = kBottomNavigationBarHeight,
    this.elevation = 4.0,
    this.blurStrength = 15.0,
    this.opacity = 0.3,
    this.gradient,
    this.borderGradient,
    this.borderWidth = 0.0,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24.0,
    this.selectedFontSize = 12.0,
    this.unselectedFontSize = 12.0,
    this.selectedFontWeight = FontWeight.w600,
    this.unselectedFontWeight = FontWeight.normal,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
    this.type = BottomNavigationBarType.fixed,
    this.shape,
    this.selectedItemBackgroundColor,
    this.unselectedItemBackgroundColor,
    this.selectedItemElevation,
    this.unselectedItemElevation,
    this.margin,
    this.borderRadius,
    this.shadowColor,
    this.shadowBlurRadius = 10.0,
    this.shadowSpreadRadius = 0.0,
    this.shadowOffset = Offset.zero,
    this.showShadow = true,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableFeedback = true,
    this.materialTapTargetSize,
    this.barBackgroundColor,
    this.barElevation,
    this.barHeight,
    this.barPadding,
    this.barWidth,
    this.barColor,
    this.barGradient,
    this.barBorderRadius,
    this.barBorderWidth,
    this.barBorderColor,
    this.barBorderGradient,
    this.barBlurStrength,
    this.barOpacity,
    this.barShadowColor,
    this.barShadowBlurRadius,
    this.barShadowSpreadRadius,
    this.barShadowOffset,
    this.showBarShadow,
    this.barMargin,
    this.barInnerPadding,
    this.barAlignment,
    this.barClipBehavior,
    this.barSemanticContainer,
    this.onBarTap,
    this.onBarDoubleTap,
    this.onBarLongPress,
    this.onBarEnter,
    this.onBarExit,
    this.onBarHover,
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
            effectiveBackgroundColor.withValues(alpha: 0.9),
            effectiveBackgroundColor.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final bottomNavBar = BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
      unselectedItemColor:
          unselectedItemColor ??
          theme.colorScheme.onSurface.withValues(alpha: 0.6),
      selectedFontSize: selectedFontSize ?? 12.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      // Removed selectedFontWeight and unselectedFontWeight from here
      showSelectedLabels: showSelectedLabels ?? true,
      showUnselectedLabels: showUnselectedLabels ?? true,
      type: type,
      iconSize: iconSize ?? 24.0,
      selectedLabelStyle: TextStyle(
        fontSize: selectedFontSize,
        fontWeight: selectedFontWeight,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: unselectedFontSize,
        fontWeight: unselectedFontWeight,
      ),
      selectedIconTheme: IconThemeData(
        size: iconSize,
        color: selectedItemColor ?? theme.colorScheme.primary,
      ),
      unselectedIconTheme: IconThemeData(
        size: iconSize,
        color:
            unselectedItemColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      enableFeedback: enableFeedback,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      mouseCursor: SystemMouseCursors.click,
      // Removed selectedItemBackgroundColor, unselectedItemBackgroundColor, selectedItemElevation, unselectedItemElevation from here
    );

    Widget glassBar = Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassContainer(
        height: height,
        width: barWidth ?? double.infinity,
        gradient: effectiveGradient,
        borderGradient: borderGradient,
        borderWidth: borderGradient != null ? borderWidth : 0.0,
        borderColor: borderGradient == null ? effectiveBorderColor : null,
        borderRadius: borderRadius ?? BorderRadius.circular(20.0),
        blur: blurStrength,
        color: effectiveBackgroundColor.withValues(alpha: opacity),
        elevation: elevation,
        shadowColor: shadowColor,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(20.0),
          child: bottomNavBar,
        ),
      ),
    );

    if (showShadow) {
      glassBar = Container(
        margin:
            margin ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? Colors.black12,
              blurRadius: shadowBlurRadius ?? 10.0,
              spreadRadius: shadowSpreadRadius ?? 0.0,
              offset: shadowOffset ?? const Offset(0, 2),
            ),
          ],
        ),
        child: GlassContainer(
          height: height,
          width: barWidth ?? double.infinity,
          gradient: effectiveGradient,
          borderGradient: borderGradient,
          borderWidth: borderGradient != null ? borderWidth : 0.0,
          borderColor: borderGradient == null ? effectiveBorderColor : null,
          borderRadius: borderRadius ?? BorderRadius.circular(20.0),
          blur: blurStrength,
          color: effectiveBackgroundColor.withValues(alpha: opacity),
          elevation: 0.0,
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(20.0),
            child: bottomNavBar,
          ),
        ),
      );
    }

    return glassBar;
  }

  /// Creates a primary bottom navigation bar with the app's primary color
  factory GlassBottomNavigationBar.primary({
    required BuildContext context,
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
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
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? iconSize,
    double? selectedFontSize,
    double? unselectedFontSize,
    FontWeight? selectedFontWeight,
    FontWeight? unselectedFontWeight,
    bool? showSelectedLabels,
    bool? showUnselectedLabels,
    BottomNavigationBarType? type,
    NotchedShape? shape,
    Color? selectedItemBackgroundColor,
    Color? unselectedItemBackgroundColor,
    double? selectedItemElevation,
    double? unselectedItemElevation,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    Offset? shadowOffset,
    bool? showShadow,
    Curve? animationCurve,
    Duration? animationDuration,
    bool? enableFeedback,
    MaterialTapTargetSize? materialTapTargetSize,
    Color? barBackgroundColor,
    double? barElevation,
    double? barHeight,
    EdgeInsetsGeometry? barPadding,
    double? barWidth,
    Color? barColor,
    Gradient? barGradient,
    BorderRadius? barBorderRadius,
    double? barBorderWidth,
    Color? barBorderColor,
    Gradient? barBorderGradient,
    double? barBlurStrength,
    double? barOpacity,
    Color? barShadowColor,
    double? barShadowBlurRadius,
    double? barShadowSpreadRadius,
    Offset? barShadowOffset,
    bool? showBarShadow,
    EdgeInsetsGeometry? barMargin,
    EdgeInsetsGeometry? barInnerPadding,
    Alignment? barAlignment,
    Clip? barClipBehavior,
    bool? barSemanticContainer,
    GestureTapCallback? onBarTap,
    GestureTapCallback? onBarDoubleTap,
    GestureLongPressCallback? onBarLongPress,
    PointerEnterEventListener? onBarEnter,
    PointerExitEventListener? onBarExit,
    ValueChanged<bool>? onBarHover,
  }) {
    final theme = Theme.of(context);
    // final isDarkMode = theme.brightness == Brightness.dark; // Unused variable

    return GlassBottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      height: height ?? kBottomNavigationBarHeight,
      elevation: elevation ?? 4.0,
      blurStrength: blurStrength ?? 15.0,
      opacity: opacity ?? 0.3,
      gradient:
          gradient ??
          LinearGradient(
            colors: [
              theme.colorScheme.primary.withAlpha((0.9 * 255).round()),
              theme.colorScheme.primary.withAlpha((0.7 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      borderGradient:
          borderGradient ??
          LinearGradient(
            colors: [
              theme.colorScheme.primary.withAlpha((0.8 * 255).round()),
              theme.colorScheme.secondary.withAlpha((0.8 * 255).round()),
            ],
          ),
      borderWidth: borderWidth ?? 0.5,
      borderColor:
          borderColor ??
          theme.colorScheme.primary.withAlpha((0.3 * 255).round()),
      backgroundColor:
          backgroundColor ??
          theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
      padding: padding,
      selectedItemColor: selectedItemColor ?? theme.colorScheme.onPrimary,
      unselectedItemColor:
          unselectedItemColor ??
          theme.colorScheme.onPrimary.withAlpha((0.7 * 255).round()),
      iconSize: iconSize ?? 24.0,
      selectedFontSize: selectedFontSize ?? 12.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      selectedFontWeight: selectedFontWeight ?? FontWeight.w600,
      unselectedFontWeight: unselectedFontWeight ?? FontWeight.normal,
      showSelectedLabels: showSelectedLabels ?? true,
      showUnselectedLabels: showUnselectedLabels ?? true,
      type: type ?? BottomNavigationBarType.fixed,
      shape: shape,
      selectedItemBackgroundColor:
          selectedItemBackgroundColor ??
          theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
      unselectedItemBackgroundColor:
          unselectedItemBackgroundColor ?? Colors.transparent,
      selectedItemElevation: selectedItemElevation ?? 2.0,
      unselectedItemElevation: unselectedItemElevation ?? 0.0,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      shadowColor:
          shadowColor ??
          theme.colorScheme.shadow.withAlpha((0.1 * 255).round()),
      shadowBlurRadius: shadowBlurRadius ?? 10.0,
      shadowSpreadRadius: shadowSpreadRadius ?? 0.0,
      shadowOffset: shadowOffset ?? const Offset(0, 2),
      showShadow: showShadow ?? true,
      animationCurve: animationCurve ?? Curves.easeInOut,
      animationDuration: animationDuration ?? const Duration(milliseconds: 200),
      enableFeedback: enableFeedback ?? true,
      materialTapTargetSize: materialTapTargetSize,
      barBackgroundColor: barBackgroundColor,
      barElevation: barElevation,
      barHeight: barHeight,
      barPadding: barPadding,
      barWidth: barWidth,
      barColor: barColor ?? theme.colorScheme.primary,
      barGradient: barGradient,
      barBorderRadius: barBorderRadius,
      barBorderWidth: barBorderWidth,
      barBorderColor: barBorderColor,
      barBorderGradient: barBorderGradient,
      barBlurStrength: barBlurStrength,
      barOpacity: barOpacity,
      barShadowColor: barShadowColor,
      barShadowBlurRadius: barShadowBlurRadius,
      barShadowSpreadRadius: barShadowSpreadRadius,
      barShadowOffset: barShadowOffset,
      showBarShadow: showBarShadow,
      barMargin: barMargin,
      barInnerPadding: barInnerPadding,
      barAlignment: barAlignment,
      barClipBehavior: barClipBehavior,
      barSemanticContainer: barSemanticContainer,
      onBarTap: onBarTap,
      onBarDoubleTap: onBarDoubleTap,
      onBarLongPress: onBarLongPress,
      onBarEnter: onBarEnter,
      onBarExit: onBarExit,
      onBarHover: onBarHover,
    );
  }

  /// Creates a secondary bottom navigation bar with a more subtle appearance
  factory GlassBottomNavigationBar.secondary({
    required BuildContext context,
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
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
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? iconSize,
    double? selectedFontSize,
    double? unselectedFontSize,
    FontWeight? selectedFontWeight,
    FontWeight? unselectedFontWeight,
    bool? showSelectedLabels,
    bool? showUnselectedLabels,
    BottomNavigationBarType? type,
    NotchedShape? shape,
    Color? selectedItemBackgroundColor,
    Color? unselectedItemBackgroundColor,
    double? selectedItemElevation,
    double? unselectedItemElevation,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    Offset? shadowOffset,
    bool? showShadow,
    Curve? animationCurve,
    Duration? animationDuration,
    bool? enableFeedback,
    MaterialTapTargetSize? materialTapTargetSize,
    Color? barBackgroundColor,
    double? barElevation,
    double? barHeight,
    EdgeInsetsGeometry? barPadding,
    double? barWidth,
    Color? barColor,
    Gradient? barGradient,
    BorderRadius? barBorderRadius,
    double? barBorderWidth,
    Color? barBorderColor,
    Gradient? barBorderGradient,
    double? barBlurStrength,
    double? barOpacity,
    Color? barShadowColor,
    double? barShadowBlurRadius,
    double? barShadowSpreadRadius,
    Offset? barShadowOffset,
    bool? showBarShadow,
    EdgeInsetsGeometry? barMargin,
    EdgeInsetsGeometry? barInnerPadding,
    Alignment? barAlignment,
    Clip? barClipBehavior,
    bool? barSemanticContainer,
    GestureTapCallback? onBarTap,
    GestureTapCallback? onBarDoubleTap,
    GestureLongPressCallback? onBarLongPress,
    PointerEnterEventListener? onBarEnter,
    PointerExitEventListener? onBarExit,
    ValueChanged<bool>? onBarHover,
  }) {
    final theme = Theme.of(context);
    // final isDarkMode = theme.brightness == Brightness.dark; // Unused variable

    return GlassBottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      height: height ?? kBottomNavigationBarHeight,
      elevation: elevation ?? 2.0,
      blurStrength: blurStrength ?? 10.0,
      opacity: opacity ?? 0.2,
      gradient:
          gradient ??
          LinearGradient(
            colors: [
              theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
              theme.colorScheme.surface.withAlpha((0.4 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      borderGradient: borderGradient,
      borderWidth: borderWidth ?? 0.5,
      borderColor:
          borderColor ??
          theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
      backgroundColor:
          backgroundColor ??
          theme.colorScheme.surface.withAlpha((0.2 * 255).round()),
      padding: padding,
      selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
      unselectedItemColor:
          unselectedItemColor ??
          theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
      iconSize: iconSize ?? 24.0,
      selectedFontSize: selectedFontSize ?? 12.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      selectedFontWeight: selectedFontWeight ?? FontWeight.w600,
      unselectedFontWeight: unselectedFontWeight ?? FontWeight.normal,
      showSelectedLabels: showSelectedLabels ?? true,
      showUnselectedLabels: showUnselectedLabels ?? true,
      type: type ?? BottomNavigationBarType.fixed,
      shape: shape,
      selectedItemBackgroundColor:
          selectedItemBackgroundColor ??
          theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
      unselectedItemBackgroundColor:
          unselectedItemBackgroundColor ?? Colors.transparent,
      selectedItemElevation: selectedItemElevation ?? 1.0,
      unselectedItemElevation: unselectedItemElevation ?? 0.0,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      shadowColor:
          shadowColor ??
          theme.colorScheme.shadow.withAlpha((0.05 * 255).round()),
      shadowBlurRadius: shadowBlurRadius ?? 8.0,
      shadowSpreadRadius: shadowSpreadRadius ?? 0.0,
      shadowOffset: shadowOffset ?? const Offset(0, 1),
      showShadow: showShadow ?? true,
      animationCurve: animationCurve ?? Curves.easeInOut,
      animationDuration: animationDuration ?? const Duration(milliseconds: 200),
      enableFeedback: enableFeedback ?? true,
      materialTapTargetSize: materialTapTargetSize,
      barBackgroundColor: barBackgroundColor,
      barElevation: barElevation,
      barHeight: barHeight,
      barPadding: barPadding,
      barWidth: barWidth,
      barColor: barColor ?? theme.colorScheme.surface,
      barGradient: barGradient,
      barBorderRadius: barBorderRadius,
      barBorderWidth: barBorderWidth,
      barBorderColor: barBorderColor,
      barBorderGradient: barBorderGradient,
      barBlurStrength: barBlurStrength,
      barOpacity: barOpacity,
      barShadowColor: barShadowColor,
      barShadowBlurRadius: barShadowBlurRadius,
      barShadowSpreadRadius: barShadowSpreadRadius,
      barShadowOffset: barShadowOffset,
      showBarShadow: showBarShadow,
      barMargin: barMargin,
      barInnerPadding: barInnerPadding,
      barAlignment: barAlignment,
      barClipBehavior: barClipBehavior,
      barSemanticContainer: barSemanticContainer,
      onBarTap: onBarTap,
      onBarDoubleTap: onBarDoubleTap,
      onBarLongPress: onBarLongPress,
      onBarEnter: onBarEnter,
      onBarExit: onBarExit,
      onBarHover: onBarHover,
    );
  }

  /// Creates a transparent bottom navigation bar with minimal styling
  factory GlassBottomNavigationBar.transparent({
    required BuildContext context,
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    double? height,
    double? blurStrength,
    double? opacity,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? iconSize,
    double? selectedFontSize,
    double? unselectedFontSize,
    FontWeight? selectedFontWeight,
    FontWeight? unselectedFontWeight,
    bool? showSelectedLabels,
    bool? showUnselectedLabels,
    PreferredSizeWidget? bottom,
    double? bottomHeight,
    BorderRadius? borderRadius,
    double? toolbarHeight,
    double? leadingWidth,
    bool? centerTitle,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
  }) {
    final theme = Theme.of(context);
    // final isDarkMode = theme.brightness == Brightness.dark; // Unused variable

    return GlassBottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap, // Pass the correct onTap here
      height: height ?? kBottomNavigationBarHeight,
      elevation: 0.0,
      blurStrength: blurStrength ?? 5.0,
      opacity: opacity ?? 0.1,
      backgroundColor: backgroundColor ?? Colors.transparent,
      borderWidth: 0.0,
      padding: padding,
      selectedItemColor: selectedItemColor ?? theme.colorScheme.primary,
      unselectedItemColor:
          unselectedItemColor ??
          theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
      iconSize: iconSize ?? 24.0,
      selectedFontSize: selectedFontSize ?? 12.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      selectedFontWeight: selectedFontWeight ?? FontWeight.w600,
      unselectedFontWeight: unselectedFontWeight ?? FontWeight.normal,
      showSelectedLabels: showSelectedLabels ?? true,
      showUnselectedLabels: showUnselectedLabels ?? true,
      type: BottomNavigationBarType.fixed,
      shape: null,
      selectedItemBackgroundColor:
          selectedItemColor?.withAlpha((0.1 * 255).round()) ??
          theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
      unselectedItemBackgroundColor: Colors.transparent,
      selectedItemElevation: 0.0,
      unselectedItemElevation: 0.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      shadowColor: Colors.transparent,
      shadowBlurRadius: 0.0,
      shadowSpreadRadius: 0.0,
      shadowOffset: Offset.zero,
      showShadow: false,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 200),
      enableFeedback: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      barBackgroundColor: Colors.transparent,
      barElevation: 0.0,
      barHeight: height,
      barPadding: padding,
      barWidth: null,
      barColor: Colors.transparent,
      barGradient: null,
      barBorderRadius: borderRadius,
      barBorderWidth: 0.0,
      barBorderColor: Colors.transparent,
      barBorderGradient: null,
      barBlurStrength: blurStrength ?? 5.0,
      barOpacity: opacity ?? 0.1,
      barShadowColor: Colors.transparent,
      barShadowBlurRadius: 0.0,
      barShadowSpreadRadius: 0.0,
      barShadowOffset: Offset.zero,
      showBarShadow: false,
      barMargin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      barInnerPadding: padding,
      barAlignment: Alignment.center,
      barClipBehavior: Clip.antiAlias,
      barSemanticContainer: true,
      onBarTap:
          null, // This onTap belongs to the GlassBottomNavigationBar itself, not the inner BottomNavigationBar
      onBarDoubleTap: onDoubleTap,
      onBarLongPress: onLongPress,
      onBarEnter: onEnter,
      onBarExit: onExit,
      onBarHover: onHover,
    );
  }
}

// Extension to create glass bottom navigation bars directly from theme
extension GlassBottomNavigationBarThemeExtension on ThemeData {
  GlassBottomNavigationBar glassBottomNavigationBar({
    required BuildContext context,
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
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
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? iconSize,
    double? selectedFontSize,
    double? unselectedFontSize,
    FontWeight? selectedFontWeight,
    FontWeight? unselectedFontWeight,
    bool? showSelectedLabels,
    bool? showUnselectedLabels,
    BottomNavigationBarType? type,
    NotchedShape? shape,
    Color? selectedItemBackgroundColor,
    Color? unselectedItemBackgroundColor,
    double? selectedItemElevation,
    double? unselectedItemElevation,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    Color? shadowColor,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    Offset? shadowOffset,
    bool? showShadow,
    Curve? animationCurve,
    Duration? animationDuration,
    bool? enableFeedback,
    MaterialTapTargetSize? materialTapTargetSize,
    Color? barBackgroundColor,
    double? barElevation,
    double? barHeight,
    EdgeInsetsGeometry? barPadding,
    double? barWidth,
    Color? barColor,
    Gradient? barGradient,
    BorderRadius? barBorderRadius,
    double? barBorderWidth,
    Color? barBorderColor,
    Gradient? barBorderGradient,
    double? barBlurStrength,
    double? barOpacity,
    Color? barShadowColor,
    double? barShadowBlurRadius,
    double? barShadowSpreadRadius,
    Offset? barShadowOffset,
    bool? showBarShadow,
    EdgeInsetsGeometry? barMargin,
    EdgeInsetsGeometry? barInnerPadding,
    Alignment? barAlignment,
    Clip? barClipBehavior,
    bool? barSemanticContainer,
    GestureTapCallback? onBarTap,
    GestureTapCallback? onBarDoubleTap,
    GestureLongPressCallback? onBarLongPress,
    PointerEnterEventListener? onBarEnter,
    PointerExitEventListener? onBarExit,
    ValueChanged<bool>? onBarHover,
  }) {
    return GlassBottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      height: height ?? kBottomNavigationBarHeight,
      elevation: elevation ?? 4.0,
      blurStrength: blurStrength ?? 15.0,
      opacity: opacity ?? 0.3,
      gradient: gradient,
      borderGradient: borderGradient,
      borderWidth: borderWidth ?? 0.0,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      padding: padding,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      iconSize: iconSize ?? 24.0,
      selectedFontSize: selectedFontSize ?? 12.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      selectedFontWeight: selectedFontWeight ?? FontWeight.w600,
      unselectedFontWeight: unselectedFontWeight ?? FontWeight.normal,
      showSelectedLabels: showSelectedLabels ?? true,
      showUnselectedLabels: showUnselectedLabels ?? true,
      type: type ?? BottomNavigationBarType.fixed,
      shape: shape,
      selectedItemBackgroundColor: selectedItemBackgroundColor,
      unselectedItemBackgroundColor: unselectedItemBackgroundColor,
      selectedItemElevation: selectedItemElevation,
      unselectedItemElevation: unselectedItemElevation,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      shadowColor: shadowColor ?? Colors.black12,
      shadowBlurRadius: shadowBlurRadius ?? 10.0,
      shadowSpreadRadius:
          shadowBlurRadius ?? 0.0, // Corrected spreadRadius default
      shadowOffset: shadowOffset ?? const Offset(0, 2),
      showShadow: showShadow ?? true,
      animationCurve: animationCurve ?? Curves.easeInOut,
      animationDuration: animationDuration ?? const Duration(milliseconds: 200),
      enableFeedback: enableFeedback ?? true,
      materialTapTargetSize: materialTapTargetSize,
      barBackgroundColor: barBackgroundColor,
      barElevation: barElevation,
      barHeight: barHeight,
      barPadding: barPadding,
      barWidth: barWidth,
      barColor: barColor,
      barGradient: barGradient,
      barBorderRadius: barBorderRadius,
      barBorderWidth: barBorderWidth,
      barBorderColor: barBorderColor,
      barBorderGradient: barBorderGradient,
      barBlurStrength: barBlurStrength,
      barOpacity: barOpacity,
      barShadowColor: barShadowColor,
      barShadowBlurRadius: barShadowBlurRadius,
      barShadowSpreadRadius: barShadowSpreadRadius,
      barShadowOffset: barShadowOffset,
      showBarShadow: showBarShadow,
      barMargin: barMargin,
      barInnerPadding: barInnerPadding,
      barAlignment: barAlignment,
      barClipBehavior: barClipBehavior,
      barSemanticContainer: barSemanticContainer,
      onBarTap: onBarTap,
      onBarDoubleTap: onBarDoubleTap,
      onBarLongPress: onBarLongPress,
      onBarEnter: onBarEnter,
      onBarExit: onBarExit,
      onBarHover: onBarHover,
    );
  }
}
