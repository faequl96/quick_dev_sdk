import 'package:flutter/material.dart';

class const CardContainer({
  super.key,
  final double? width,
  final double? height,
  final BoxConstraints? constraints,
  final EdgeInsets? margin,
  final EdgeInsets padding = .zero,
  final Color? color,
  final LinearGradient? gradientColor,
  final double borderRadius = 8,
  final BoxBorder? border,
  final BoxShadow? boxShadow,
  final Clip clipBehavior = .none,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: .circular(borderRadius),
        border: border,
        boxShadow: [
          if (boxShadow != null)
            boxShadow!
          else
            const BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 6,
              color: Colors.black12,
              spreadRadius: 1,
            ),
        ],
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
