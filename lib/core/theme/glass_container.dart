import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 0,
    this.opacity = 1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF111827),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border ?? Border.all(color: const Color(0xFF374151), width: 1.0),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.5), 
             blurRadius: 20,
             spreadRadius: 0,
             offset: const Offset(0, 10),
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
