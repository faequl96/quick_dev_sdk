import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class StaticHeightTextField extends StatefulWidget {
  const StaticHeightTextField({
    super.key,
    this.width,
    required this.height,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.style,
    this.decoration,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.onEditingComplete,
  });

  final double? width;
  final double height;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextStyle? style;
  final FieldDecoration? decoration;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String value)? onChanged;
  final TextFieldValidator Function(String value)? validator;
  final void Function()? onEditingComplete;

  @override
  State<StaticHeightTextField> createState() => _StaticHeightTextFieldState();
}

class _StaticHeightTextFieldState extends State<StaticHeightTextField> {
  String? _validateMessage;

  void _onChangeListener() {
    if (widget.controller.text.isEmpty) _validateMessage = null;
    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(_onChangeListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    widget.controller.dispose();
    widget.focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            style: widget.style,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            obscureText: widget.decoration?.obscureText ?? false,
            obscuringCharacter: widget.decoration?.obscuringCharacter ?? '•',
            textAlignVertical: widget.decoration?.border is OutlineInputBorder
                ? TextAlignVertical.center
                : null,
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
            decoration: InputDecoration(
              labelText: widget.decoration?.labelText,
              labelStyle: widget.decoration?.labelStyle,
              floatingLabelBehavior: widget.decoration?.floatingLabelBehavior,
              hintText: widget.decoration?.hintText,
              hintStyle: widget.decoration?.hintStyle,
              prefixIcon: widget.decoration?.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: GeneralEffectsButton(
                        onTap: () =>
                            widget.decoration?.prefixIcon?.onTap.call(),
                        hoveredColor: Colors.grey.shade300,
                        splashColor: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(30),
                        child: widget.decoration?.prefixIcon?.child,
                      ),
                    )
                  : null,
              suffixIcon: widget.decoration?.suffixIcon != null &&
                      (widget.decoration?.hideSuffixIconOnEmpty == false ||
                          (widget.decoration?.hideSuffixIconOnEmpty == true &&
                              widget.controller.text.isNotEmpty))
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: GeneralEffectsButton(
                        onTap: () =>
                            widget.decoration?.suffixIcon?.onTap.call(),
                        hoveredColor: Colors.grey.shade300,
                        splashColor: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(30),
                        child: widget.decoration?.suffixIcon?.child,
                      ),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.decoration?.contentHorizontalPadding ?? 12,
                vertical: 0,
              ),
              enabledBorder: widget.decoration?.border ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
              focusedBorder: widget.decoration?.border ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
            ),
          ),
        ),
        if (_validateMessage != null)
          Row(
            children: [
              const SizedBox(width: 1),
              Flexible(
                child: Text(
                  _validateMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class FieldDecoration {
  FieldDecoration({
    this.contentHorizontalPadding = 12,
    this.prefixIcon,
    this.suffixIcon,
    this.hideSuffixIconOnEmpty = false,
    this.border = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26),
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

  final double contentHorizontalPadding;
  final PreSufFixIcon? prefixIcon;
  final PreSufFixIcon? suffixIcon;
  final bool hideSuffixIconOnEmpty;
  final InputBorder border;
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
  late String message;
}

enum ValidatePosition { bottomOutside, rightInside }
