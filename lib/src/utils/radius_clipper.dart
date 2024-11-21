import 'package:flutter/material.dart';

class RadiusClipper extends CustomClipper<Path> {
  RadiusClipper({
    TextDirection? textDirection,
    required this.borderRadius,
  })  : textDirection = textDirection ?? TextDirection.ltr,
        _decoration = BoxDecoration(borderRadius: borderRadius);

  final TextDirection textDirection;
  final BorderRadius borderRadius;
  final Decoration _decoration;

  @override
  Path getClip(Size size) {
    return _decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(RadiusClipper oldClipper) {
    return oldClipper._decoration != _decoration ||
        oldClipper.textDirection != textDirection;
  }
}
