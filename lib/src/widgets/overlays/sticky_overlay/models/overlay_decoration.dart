part of '../sticky_overlay.dart';

class _OverlayDecoration {
  const _OverlayDecoration({
    this.height,
    this.width,
    required this.padding,
    required this.color,
    required this.borderRadius,
    required this.border,
    required this.elevation,
    required this.elevationType,
  });

  final double? height;
  final double? width;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final BoxBorder border;
  final double elevation;
  final ElevationType elevationType;
}
