import 'package:flutter/material.dart';

class PreSufFixIcon {
  PreSufFixIcon({required this.onTap, required this.child});

  final void Function() onTap;
  final Widget child;
}

class TextFieldValidator {
  TextFieldValidator.success() : isSuccess = true;
  TextFieldValidator.failed({required this.message}) : isSuccess = false;

  final bool isSuccess;
  late Widget message;
}
