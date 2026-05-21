import 'package:flutter/material.dart';

enum ElevationType { elevation, shadow }

class DecorationUtils {
  const DecorationUtils._();

  static List<BoxShadow> elevation(
    double value, {
    required ElevationType elevationType,
    Color color = Colors.black,
  }) {
    if (value <= 0) return [];

    if (elevationType == .elevation) {
      return [
        BoxShadow(
          color: color.withValues(alpha: .001 + (value * .08).clamp(.0, .1)),
          offset: const Offset(0, .15),
          blurRadius: value * value * .01,
        ),
        BoxShadow(
          color: color.withValues(alpha: .02 + (value * .16).clamp(.0, .18)),
          offset: Offset(0, .02 + (value - value * value * .005)),
          blurRadius: value * value * .06,
          spreadRadius: value * value * .0015,
        ),
      ];
    }

    return [
      BoxShadow(
        color: color.withValues(alpha: .05 + (value * .05).clamp(.0, .05)),
        offset: Offset(0, value * 1.5),
        blurRadius: value * 5,
      ),
    ];
  }
}
