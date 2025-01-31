part of 'show_modal.dart';

class BottomSheetDecoration {
  BottomSheetDecoration({
    this.height,
    this.color,
    this.borderSide = BorderSide.none,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    ),
    this.clipBehavior = Clip.none,
  });

  final double? height;
  final Color? color;
  final BorderSide borderSide;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
}

class DialogDecoration {
  DialogDecoration({
    this.width,
    this.height,
    this.color = Colors.white,
    this.elevation = 24,
    this.shadowColor = Colors.black12,
    this.borderSide = BorderSide.none,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.clipBehavior = Clip.hardEdge,
  });

  final double? width;
  final double? height;
  final Color? color;
  final double? elevation;
  final Color? shadowColor;
  final BorderSide borderSide;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
}
