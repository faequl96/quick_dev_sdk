part of '../floating_overlay.dart';

class DialogDecoration {
  DialogDecoration({
    this.width,
    this.height,
    this.constraints,
    this.padding = .zero,
    this.color = Colors.white,
    this.elevation = 24,
    this.shadowColor = Colors.black12,
    this.borderSide = .none,
    this.borderRadius = const .all(.circular(10)),
    this.clipBehavior = .hardEdge,
  });

  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsets padding;
  final Color? color;
  final double? elevation;
  final Color? shadowColor;
  final BorderSide borderSide;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
}
