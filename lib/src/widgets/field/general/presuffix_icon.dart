import 'package:flutter/material.dart';

class PreSufFixIcon {
  PreSufFixIcon({required this.onTap, this.backgroundColor, this.hoveredColor, this.splashColor, required this.child});

  final void Function() onTap;
  final Color? backgroundColor;
  final Color? hoveredColor;
  final Color? splashColor;
  final Widget child;
}

class TextFieldValidator {
  TextFieldValidator.success() : isSuccess = true;
  TextFieldValidator.failed({required this.message}) : isSuccess = false;

  final bool isSuccess;
  late Widget message;
}
