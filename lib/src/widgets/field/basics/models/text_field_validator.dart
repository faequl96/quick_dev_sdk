import 'package:flutter/cupertino.dart';

class TextFieldValidator {
  new success() : isSuccess = true;
  new failed({required this.message}) : isSuccess = false;

  final bool isSuccess;
  late Widget message;
}
