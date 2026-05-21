import 'package:flutter/material.dart';

class SuggestionItemDecoration {
  const SuggestionItemDecoration({
    this.padding = const .symmetric(horizontal: 10, vertical: 8),
    this.margin = const .symmetric(vertical: 2),
    this.evenColor,
    this.oddColor,
    this.hoveredColor,
    this.borderRadius = 0,
  });

  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? evenColor;
  final Color? oddColor;
  final Color? hoveredColor;
  final double borderRadius;
}
