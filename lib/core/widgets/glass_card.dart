import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A glassmorphism card: a translucent container with a blurred backdrop.
///
/// `BackdropFilter` blurs whatever is rendered *behind* this widget, which is
/// why it reads as frosted glass when placed over a colorful background.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 18,
    this.padding = const EdgeInsets.all(20),
    this.borderColor = AppColors.glassBorder,
    this.fillColor = AppColors.glassFill,
    this.gradient,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color fillColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? fillColor : null,
            gradient: gradient,
            borderRadius: radius,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
