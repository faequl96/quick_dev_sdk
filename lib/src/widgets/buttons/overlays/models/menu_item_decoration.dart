import 'package:flutter/material.dart';

class MenuItemDecoration {
  const MenuItemDecoration({
    this.padding = const .symmetric(horizontal: 10, vertical: 8),
    this.margin = const .symmetric(vertical: 2),
    this.color,
    this.hoveredColor,
    this.borderRadius = 0,
  });

  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? color;
  final Color? hoveredColor;
  final double borderRadius;
}
