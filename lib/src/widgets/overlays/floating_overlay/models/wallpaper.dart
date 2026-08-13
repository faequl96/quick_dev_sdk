part of '../floating_overlay.dart';

class Wallpaper extends Positioned {
  // ignore: use_primary_constructors
  new({super.key, super.height, super.width, Position? position, required super.child})
    : super(
        left: position?.left,
        top: position?.top,
        right: position?.right,
        bottom: position?.bottom,
      );
}
