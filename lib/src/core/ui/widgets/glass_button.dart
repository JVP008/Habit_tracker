import 'package:flutter/material.dart';
import 'glass_container.dart';

/// A customizable button with a glass morphism effect
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final double width;
  final double height;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Gradient? splashGradient;
  final bool isFrostedGlass;
  final double blur;
  final double opacity;
  final bool isCircular;
  final bool isOutlined;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? borderGradient;
  final bool isGradientBorder;
  final Duration animationDuration;
  final Curve animationCurve;
  final double scaleFactor;
  final bool enableFeedback;
  final String? tooltip;
  final bool isLoading;
  final Widget? loadingChild;
  final double loadingSize;
  final Color? loadingColor;
  final double? minWidth;
  final double? maxWidth;
  final BoxConstraints? constraints;
  final bool expanded;

  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.splashGradient,
    this.isFrostedGlass = true,
    this.blur = 10.0,
    this.opacity = 0.3,
    this.isCircular = false,
    this.isOutlined = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderGradient,
    this.isGradientBorder = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.scaleFactor = 0.98,
    this.enableFeedback = true,
    this.tooltip,
    this.isLoading = false,
    this.loadingChild,
    this.loadingSize = 24.0,
    this.loadingColor,
    this.minWidth,
    this.maxWidth,
    this.constraints,
    this.expanded = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();

  // Primary button constructor
  factory GlassButton.primary({
    required BuildContext context,
    required Widget child,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool? isFrostedGlass,
    bool? isLoading,
    Widget? loadingChild,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return GlassButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      width: width ?? double.infinity,
      height: height ?? 50.0,
      borderRadius: borderRadius ?? 12.0,
      elevation: elevation ?? 4.0,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      margin: margin,
      backgroundColor: theme.colorScheme.primary,
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withAlpha((0.8 * 255).toInt()),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      splashGradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withAlpha((0.7 * 255).toInt()),
          theme.colorScheme.primary.withAlpha((0.5 * 255).toInt()),
        ],
      ),
      isFrostedGlass: isFrostedGlass ?? true,
      isGradientBorder: true,
      borderGradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withAlpha((0.8 * 255).toInt()),
          theme.colorScheme.secondary.withAlpha((0.8 * 255).toInt()),
        ],
      ),
      isLoading: isLoading ?? false,
      loadingChild: loadingChild,
      tooltip: tooltip,
      child: child,
    );
  }

  // Secondary button constructor
  factory GlassButton.secondary({
    required BuildContext context,
    required Widget child,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool? isFrostedGlass,
    bool? isLoading,
    Widget? loadingChild,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return GlassButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      width: width ?? double.infinity,
      height: height ?? 50.0,
      borderRadius: borderRadius ?? 12.0,
      elevation: elevation ?? 2.0,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      margin: margin,
      backgroundColor: theme.colorScheme.secondaryContainer,
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.secondaryContainer.withAlpha((0.8 * 255).toInt()),
        ],
      ),
      isFrostedGlass: isFrostedGlass ?? true,
      borderColor: theme.colorScheme.secondary,
      borderWidth: 1.0,
      isLoading: isLoading ?? false,
      loadingChild: loadingChild,
      tooltip: tooltip,
      child: child,
    );
  }

  // Text button constructor
  factory GlassButton.text({
    required BuildContext context,
    required Widget child,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    double? borderRadius,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool? isFrostedGlass,
    bool? isLoading,
    Widget? loadingChild,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return GlassButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      width: width ?? double.infinity,
      height: height ?? 40.0,
      borderRadius: borderRadius ?? 8.0,
      elevation: 0,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: margin,
      backgroundColor: Colors.transparent,
      isFrostedGlass: isFrostedGlass ?? false,
      opacity: 0.1,
      isLoading: isLoading ?? false,
      loadingChild: loadingChild,
      tooltip: tooltip,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }

  // Icon button constructor
  factory GlassButton.icon({
    required BuildContext context,
    required Widget icon,
    required Widget label,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    bool? isFrostedGlass,
    bool? isLoading,
    Widget? loadingChild,
    String? tooltip,
    double? iconSize,
    double spacing = 8.0,
  }) {
    return GlassButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      width: width ?? double.infinity,
      height: height ?? 50.0,
      borderRadius: borderRadius ?? 12.0,
      elevation: elevation ?? 4.0,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: margin,
      backgroundColor: backgroundColor,
      isFrostedGlass: isFrostedGlass ?? true,
      isLoading: isLoading ?? false,
      loadingChild: loadingChild,
      tooltip: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconSize != null)
            SizedBox(width: iconSize, height: iconSize, child: icon)
          else
            icon,
          SizedBox(width: spacing),
          Flexible(child: label),
        ],
      ),
    );
  }
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.animationCurve,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isLoading) return;
    _animationController.reverse();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isLoading) return;
    _resetState();
  }

  void _handleTapCancel() {
    if (widget.isLoading) return;
    _resetState();
  }

  void _resetState() {
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor =
        widget.borderColor ??
        theme.colorScheme.outline.withAlpha((0.3 * 255).toInt());

    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: GlassContainer(
        width: widget.width,
        height: widget.height,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        blur: widget.blur,
        opacity: widget.opacity,
        elevation: widget.elevation,
        padding: widget.padding,
        margin: widget.margin,
        color: widget.backgroundColor,
        gradient: widget.gradient,
        isFrostedGlass: widget.isFrostedGlass,
        isCircular: widget.isCircular,
        border: widget.isOutlined
            ? Border.all(color: effectiveBorderColor, width: widget.borderWidth)
            : null,
        isGradientBorder: widget.isGradientBorder,
        gradientBorder: widget.borderGradient != null
            ? GradientBorder(
                gradient: widget.borderGradient!,
                width: widget.borderWidth,
              )
            : null,
        constraints:
            widget.constraints ??
            BoxConstraints(
              minWidth: widget.minWidth ?? 0.0,
              maxWidth: widget.maxWidth ?? double.infinity,
              minHeight: widget.height,
            ),
        child: widget.isLoading
            ? Center(
                child:
                    widget.loadingChild ??
                    SizedBox(
                      width: widget.loadingSize,
                      height: widget.loadingSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.loadingColor ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
              )
            : widget.child,
      ),
    );

    // Wrap with expanded if needed
    if (widget.expanded) {
      button = Expanded(child: button);
    }

    // Add splash effect
    button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        onLongPress: widget.isLoading ? null : widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: button,
      ),
    );

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

// Extension to create buttons directly from theme
extension GlassButtonThemeExtension on ThemeData {
  GlassButton glassButton({
    required Widget child,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
    double width = double.infinity,
    double height = 50.0,
    double borderRadius = 12.0,
    double elevation = 4.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    Gradient? gradient,
    Gradient? splashGradient,
    bool isFrostedGlass = true,
    double blur = 10.0,
    double opacity = 0.3,
    bool isCircular = false,
    bool isOutlined = false,
    Color? borderColor,
    double borderWidth = 1.0,
    Gradient? borderGradient,
    bool isGradientBorder = false,
    Duration animationDuration = const Duration(milliseconds: 200),
    Curve animationCurve = Curves.easeInOut,
    double scaleFactor = 0.98,
    bool enableFeedback = true,
    String? tooltip,
    bool isLoading = false,
    Widget? loadingChild,
    double loadingSize = 24.0,
    Color? loadingColor,
    double? minWidth,
    double? maxWidth,
    BoxConstraints? constraints,
    bool expanded = false,
  }) {
    return GlassButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      width: width,
      height: height,
      borderRadius: borderRadius,
      elevation: elevation,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      gradient: gradient,
      splashGradient: splashGradient,
      isFrostedGlass: isFrostedGlass,
      blur: blur,
      opacity: opacity,
      isCircular: isCircular,
      isOutlined: isOutlined,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderGradient: borderGradient,
      isGradientBorder: isGradientBorder,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      scaleFactor: scaleFactor,
      enableFeedback: enableFeedback,
      tooltip: tooltip,
      isLoading: isLoading,
      loadingChild: loadingChild,
      loadingSize: loadingSize,
      loadingColor: loadingColor,
      minWidth: minWidth,
      maxWidth: maxWidth,
      constraints: constraints,
      expanded: expanded,
      child: child,
    );
  }
}
