import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReliefCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool concave; // Effect when pressed or inset
  final Gradient? gradient;
  final Color? color;

  const ReliefCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.elevation = 8,
    this.borderRadius,
    this.padding,
    this.concave = false,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(32);
    
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: effectiveBorderRadius,
        gradient: gradient ?? (concave ? null : AppColors.reliefGradient),
        boxShadow: concave 
          ? [
              // Inset shadow (concave look)
              BoxShadow(
                color: AppColors.darkShadow.withOpacity(0.5),
                offset: const Offset(4, 4),
                blurRadius: 10,
                spreadRadius: -2,
              ),
              const BoxShadow(
                color: AppColors.lightSource,
                offset: Offset(-4, -4),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ]
          : AppColors.reliefShadows(offset: elevation, blur: elevation * 2),
      ),
      child: child,
    );
  }
}
