import 'package:flutter/material.dart';

class AppAnimations {
  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in animation
  static Widget slideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutQuart,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      child: child,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
    );
  }

  // Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.elasticOut,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      child: child,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
    );
  }

  // Fade and slide animation
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutQuart,
    Offset offset = const Offset(0, 0.1),
  }) {
    return slideIn(
      duration: duration,
      curve: curve,
      begin: offset,
      child: fadeIn(
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }

  // Staggered list animation
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = const Duration(milliseconds: 100),
    Curve curve = Curves.easeOutQuart,
    Offset offset = const Offset(0, 0.1),
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      return AnimatedSwitcher(
        duration: duration,
        child: Container(
          key: ValueKey<int>(index),
          child: fadeSlideIn(
            duration: duration,
            curve: curve,
            offset: offset,
            child: child,
          ),
        ),
      );
    }).toList();
  }

  // Bouncing animation for buttons
  static Widget bounce({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.98,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return GestureDetector(
      onTapDown: (_) {
        // Scale down on press
        // We'll use a simple animation controller for this
      },
      onTapUp: (_) {
        // Scale back up on release
      },
      onTap: onTap,
      child: child,
    );
  }

  // Shimmer loading effect
  static Widget shimmer({
    double width = double.infinity,
    double height = 16.0,
    double radius = 4.0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // Animated page route
  static PageRouteBuilder<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
