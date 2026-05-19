part of '../floating_overlay.dart';

class BottomSheetDecoration {
  BottomSheetDecoration({
    this.height,
    this.constraints,
    this.color,
    this.backgroundContentColor,
    this.borderSide = .none,
    this.borderRadius = const .only(topLeft: .circular(10), topRight: .circular(10)),
    this.clipBehavior = .hardEdge,
  });

  final double? height;
  final BoxConstraints? constraints;
  final Color? color;
  final Color? backgroundContentColor;
  final BorderSide borderSide;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
}
