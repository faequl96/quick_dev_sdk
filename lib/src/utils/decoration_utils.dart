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
          color: color.withValues(alpha: .1 + (value * .15).clamp(.0, .15)),
          offset: Offset(0, value * .8),
          blurRadius: value * .6,
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
