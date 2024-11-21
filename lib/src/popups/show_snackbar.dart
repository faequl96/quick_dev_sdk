import 'dart:developer';

import 'package:flutter/material.dart';

class ShowSnackbar {
  ShowSnackbar._();

  static final ShowSnackbar _instance = ShowSnackbar._();
  static ShowSnackbar get instance => _instance;

  late BuildContext _context;

  void create(
    BuildContext context, {
    SnackBarDecoration? decoration,
    Duration duration = const Duration(seconds: 5),
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    _context = context;
    if (_context.mounted == false) {
      log('Your context is unmounted from widget tree');
      return;
    }

    ScaffoldMessenger.of(_context).hideCurrentSnackBar();

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        width: decoration?.width,
        padding: decoration?.padding,
        margin: decoration?.margin,
        backgroundColor: decoration?.color,
        shape: decoration?.shape,
        elevation: decoration?.elevation,
        clipBehavior: decoration?.clipBehavior ?? Clip.none,
        duration: duration,
        content: contentBuilder(_context),
      ),
    );
  }

  void remove() {
    ScaffoldMessenger.of(_context).hideCurrentSnackBar();
  }
}

class SnackBarDecoration {
  SnackBarDecoration({
    this.width,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.color,
    this.shape,
    this.elevation,
    this.clipBehavior = Clip.none,
  });

  final double? width;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Color? color;
  final ShapeBorder? shape;
  final double? elevation;
  final Clip clipBehavior;
}
