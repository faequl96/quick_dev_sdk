import 'package:flutter/material.dart';

class DropdownItemDecoration {
  const DropdownItemDecoration({
    this.padding = const .symmetric(horizontal: 10, vertical: 8),
    this.margin = const .symmetric(vertical: 2),
    this.color,
    this.selectedColor,
    this.hoveredColor,
    this.borderRadius = 0,
  });

  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? color;
  final Color? selectedColor;
  final Color? hoveredColor;
  final double borderRadius;
}
