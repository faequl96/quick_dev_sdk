import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class GeneralUnderlineTextField extends StatefulWidget {
  const GeneralUnderlineTextField({
    super.key,
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

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? enabled;
  final TextStyle style;
  final bool useBuiltInFont;
  final UnderlineFieldDecoration? decoration;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String value)? onChanged;
  final TextFieldValidator Function(String value)? validator;
  final void Function()? onEditingComplete;

  @override
  State<GeneralUnderlineTextField> createState() => _GeneralUnderlineTextFieldState();
}

class _GeneralUnderlineTextFieldState extends State<GeneralUnderlineTextField> {
  Widget? _validateMessage;

  String _lastText = '';

  void _onChangeListener() {
    if (widget.controller.text != _lastText) {
      _lastText = widget.controller.text;

      widget.onChanged?.call(widget.controller.text);
      final validate = widget.validator?.call(widget.controller.text);
      if (validate?.isSuccess != true) {
        setState(() => _validateMessage = validate?.message);
        return;
      }
      setState(() => _validateMessage = null);
    }
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onChangeListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usePrefixIcon = widget.decoration?.prefixIcon != null;
    final useSuffixIcon =
        widget.decoration?.suffixIcon != null &&
        (widget.decoration?.hideSuffixIconOnEmpty == false ||
            (widget.decoration?.hideSuffixIconOnEmpty == true && widget.controller.text.isNotEmpty));
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(textTheme: widget.useBuiltInFont ? GoogleFonts.nunitoTextTheme() : null),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            style: widget.style.copyWith(fontSize: (widget.style.fontSize ?? 16)),
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            obscureText: widget.decoration?.obscureText ?? false,
            obscuringCharacter: widget.decoration?.obscuringCharacter ?? '•',
            cursorHeight: (widget.style.fontSize ?? 16) + 10,
            decoration: InputDecoration(
              labelText: widget.decoration?.labelText,
              labelStyle: widget.decoration?.labelStyle,
              floatingLabelBehavior: widget.decoration?.floatingLabelBehavior,
              hintText: widget.decoration?.hintText,
              hintStyle: widget.decoration?.hintStyle,
              prefixIcon: usePrefixIcon ? _preSuffix(widget.decoration?.prefixIcon) : null,
              suffixIcon: useSuffixIcon ? _preSuffix(widget.decoration?.suffixIcon) : null,
              contentPadding: widget.decoration?.contentPadding,
              enabledBorder: widget.decoration?.enabledBorder,
              disabledBorder: widget.decoration?.disabledBorder,
              focusedBorder: widget.decoration?.focusedBorder,
            ),
            onEditingComplete: widget.onEditingComplete,
          ),
        ),
        if (_validateMessage != null)
          SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                const SizedBox(width: 1),
                Flexible(child: _validateMessage!),
              ],
            ),
          ),
      ],
    );
  }

  Widget _preSuffix(PreSufFixIcon? preSuffixIcon) {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 8, right: widget.decoration?.contentPadding?.right ?? 0),
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

class UnderlineFieldDecoration {
  UnderlineFieldDecoration({
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.hideSuffixIconOnEmpty = false,
    this.enabledBorder,
    this.disabledBorder,
    this.focusedBorder,
    this.labelText,
    this.labelStyle,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.hintText,
    this.hintStyle,
    this.obscuringCharacter = '•',
    this.obscureText = false,
  });

  final EdgeInsets? contentPadding;
  final PreSufFixIcon? prefixIcon;
  final PreSufFixIcon? suffixIcon;
  final bool hideSuffixIconOnEmpty;
  final UnderlineInputBorder? enabledBorder;
  final UnderlineInputBorder? disabledBorder;
  final UnderlineInputBorder? focusedBorder;
  final String? labelText;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior floatingLabelBehavior;
  final String? hintText;
  final TextStyle? hintStyle;
  final String obscuringCharacter;
  final bool obscureText;
}
