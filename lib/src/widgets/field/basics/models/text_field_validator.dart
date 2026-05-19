import 'package:flutter/cupertino.dart';

class TextFieldValidator {
  TextFieldValidator.success() : isSuccess = true;
  TextFieldValidator.failed({required this.message}) : isSuccess = false;

  final bool isSuccess;
  late Widget message;
}
