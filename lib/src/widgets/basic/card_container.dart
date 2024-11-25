import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.padding = EdgeInsets.zero,
    this.color,
    this.borderRadius = 8,
    this.border,
    this.boxShadow,
    this.clipBehavior = Clip.none,
    required this.child,
  });

  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color? color;
  final double borderRadius;
  final BoxBorder? border;
  final BoxShadow? boxShadow;
  final Clip clipBehavior;
  final Widget child;

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
        borderRadius: BorderRadius.circular(borderRadius),
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
