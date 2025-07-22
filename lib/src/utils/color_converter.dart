import 'package:flutter/material.dart';

class ColorConverter {
  ColorConverter._();

  static Color lighten(Color color, [int percent = 20]) {
    assert(percent >= 1 && percent <= 100);
    final p = percent / 100;

    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final a = (color.a * 255).round();

    return Color.fromARGB(
      a,
      (r + ((255 - r) * p)).round().clamp(0, 255),
      (g + ((255 - g) * p)).round().clamp(0, 255),
      (b + ((255 - b) * p)).round().clamp(0, 255),
    );
  }

  static Color darken(Color color, [int percent = 20]) {
    assert(percent >= 1 && percent <= 100);
    final f = 1 - (percent / 100);

    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final a = (color.a * 255).round();

    return Color.fromARGB(a, (r * f).round().clamp(0, 255), (g * f).round().clamp(0, 255), (b * f).round().clamp(0, 255));
  }
}
