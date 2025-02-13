import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class GeneralTextField extends StatefulWidget {
  const GeneralTextField({
    super.key,
    this.height,
    this.width,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled,
    this.style = const TextStyle(fontSize: 16),
    this.useBuiltInFont = true,
    this.decoration,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.onEditingComplete,
  });

  final double? height;
  final double? width;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? enabled;
  final TextStyle style;
  final bool useBuiltInFont;
  final FieldDecoration? decoration;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String value)? onChanged;
  final TextFieldValidator Function(String value)? validator;
  final void Function()? onEditingComplete;

  @override
  State<GeneralTextField> createState() => _GeneralTextFieldState();
}

class _GeneralTextFieldState extends State<GeneralTextField> {
  late final FieldDecoration? _decoration;

  Widget? _validateMessage;

  void _onChangeListener() {
    if (widget.controller.text.isEmpty) _validateMessage = null;
    setState(() {});
  }

  @override
  void initState() {
    _decoration = widget.decoration;
    widget.controller.addListener(_onChangeListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: widget.width,
        height: widget.height,
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme:
                widget.useBuiltInFont ? GoogleFonts.nunitoTextTheme() : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            style: widget.style.copyWith(
              fontSize: (widget.style.fontSize ?? 16),
            ),
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            obscureText: _decoration?.obscureText ?? false,
            obscuringCharacter: _decoration?.obscuringCharacter ?? '•',
            cursorHeight: (widget.style.fontSize ?? 16) + 10,
            decoration: InputDecoration(
              labelText: _decoration?.labelText,
              labelStyle: _decoration?.labelStyle,
              floatingLabelBehavior: _decoration?.floatingLabelBehavior,
              hintText: _decoration?.hintText,
              hintStyle: _decoration?.hintStyle,
              prefixIcon: _decoration?.prefixIcon != null
                  ? _preSuffix(_decoration?.prefixIcon)
                  : null,
              suffixIcon: _decoration?.suffixIcon != null &&
                      (_decoration?.hideSuffixIconOnEmpty == false ||
                          (_decoration?.hideSuffixIconOnEmpty == true &&
                              widget.controller.text.isNotEmpty))
                  ? _preSuffix(_decoration?.suffixIcon)
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: _decoration?.contentHorizontalPadding ?? 12,
                vertical: widget.height != null
                    ? 0
                    : 16 + (_decoration?.contentVerticalPadding ?? 0),
              ),
              enabledBorder: _decoration?.enabledBorder ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
              disabledBorder: _decoration?.disabledBorder ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
              focusedBorder: _decoration?.focusedBorder ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              final validate = widget.validator?.call(value);
              if (validate?.isSuccess != true) {
                setState(() => _validateMessage = validate?.message);
                return;
              }
              setState(() => _validateMessage = null);
            },
            onEditingComplete: widget.onEditingComplete,
          ),
        ),
      ),
      if (_validateMessage != null)
        SizedBox(
          width: widget.width,
          child: Row(children: [
            const SizedBox(width: 1),
            Flexible(child: _validateMessage!),
          ]),
        ),
    ]);
  }

  Widget _preSuffix(PreSufFixIcon? preSuffixIcon) {
    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: _decoration?.contentHorizontalPadding ?? 12,
      ),
      child: GeneralEffectsButton(
        onTap: () => preSuffixIcon?.onTap.call(),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        hoveredColor: Colors.grey.shade300,
        splashColor: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(40),
        child: preSuffixIcon?.child,
      ),
    );
  }
}

class FieldDecoration {
  FieldDecoration({
    this.contentVerticalPadding = 0,
    this.contentHorizontalPadding = 12,
    this.prefixIcon,
    this.suffixIcon,
    this.hideSuffixIconOnEmpty = false,
    this.enabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.disabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.labelText,
    this.labelStyle,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.hintText,
    this.hintStyle,
    this.obscuringCharacter = '•',
    this.obscureText = false,
  });

  final double contentVerticalPadding;
  final double contentHorizontalPadding;
  final PreSufFixIcon? prefixIcon;
  final PreSufFixIcon? suffixIcon;
  final bool hideSuffixIconOnEmpty;
  final InputBorder enabledBorder;
  final InputBorder disabledBorder;
  final InputBorder focusedBorder;
  final String? labelText;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior floatingLabelBehavior;
  final String? hintText;
  final TextStyle? hintStyle;
  final String obscuringCharacter;
  final bool obscureText;
}

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

enum ValidatePosition { bottomOutside, rightInside }
