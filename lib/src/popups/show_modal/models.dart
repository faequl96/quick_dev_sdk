part of 'show_modal.dart';

class BottomSheetDecoration {
  BottomSheetDecoration({
    this.height,
    this.constraints,
    this.color,
    this.borderSide = BorderSide.none,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
    this.clipBehavior = Clip.none,
  }) : draggable = false;

  BottomSheetDecoration.draggable({
    this.color,
    this.borderSide = BorderSide.none,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
    this.clipBehavior = Clip.none,
  }) : height = null,
       constraints = null,
       draggable = true;

  final bool draggable;
  final double? height;
  final BoxConstraints? constraints;
  final Color? color;
  final BorderSide borderSide;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
}

class DialogDecoration {
  DialogDecoration({
    this.width,
    this.height,
    this.constraints,
    this.padding = EdgeInsets.zero,
    this.color = Colors.white,
    this.elevation = 24,
    this.shadowColor = Colors.black12,
    this.borderSide = BorderSide.none,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.clipBehavior = Clip.hardEdge,
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

class Wallpaper extends Positioned {
  Wallpaper({super.key, super.height, super.width, Position? position, required super.child})
    : super(left: position?.left, top: position?.top, right: position?.right, bottom: position?.bottom);
}

class Position {
  const Position({this.left, this.top, this.right, this.bottom});

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
}
