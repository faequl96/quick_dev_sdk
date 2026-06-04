part of '../sticky_overlay.dart';

class _LayoutValues {
  const _LayoutValues({
    this.surfaceMaxWidth = 0,
    this.surfaceMaxHeight = 0,
    this.alignmentOffsetY = 0,
    this.alignmentOffsetX = 0,
    this.anchorAlignment = .topCenter,
  });

  final double surfaceMaxWidth;
  final double surfaceMaxHeight;
  final double alignmentOffsetY;
  final double alignmentOffsetX;
  final Alignment anchorAlignment;
}
