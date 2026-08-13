part of '../floating_overlay.dart';

class BottomSheetDecoration({
  final double? height,
  final BoxConstraints? constraints,
  final Color? color,
  final Color? backgroundContentColor,
  final BorderSide borderSide = .none,
  final BorderRadius borderRadius = const .only(topLeft: .circular(10), topRight: .circular(10)),
  final Clip clipBehavior = .hardEdge,
});
