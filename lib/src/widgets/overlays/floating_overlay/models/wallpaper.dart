part of '../floating_overlay.dart';

class Wallpaper extends Positioned {
  Wallpaper({super.key, super.height, super.width, Position? position, required super.child})
    : super(
        left: position?.left,
        top: position?.top,
        right: position?.right,
        bottom: position?.bottom,
      );
}
