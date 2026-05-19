import 'package:flutter/material.dart';

class PreSufFixIcon {
  PreSufFixIcon({
    required this.onTap,
    this.backgroundColor,
    this.hoveredColor,
    this.splashColor,
    required this.child,
  });

  final void Function() onTap;
  final Color? backgroundColor;
  final Color? hoveredColor;
  final Color? splashColor;
  final Widget child;
}
