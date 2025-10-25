import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.decoration,
    this.maxLines,
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
  final FieldDecoration? decoration;
  final int? maxLines;
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
  late final FocusNode _focusNode;

  Widget? _validateMessage;
  List<PreSufFixIcon> _prefixIcon = [];
  List<PreSufFixIcon> _suffixIcon = [];

  String _lastText = '';

  void _onChangeListener() {
    if (widget.controller.text != _lastText) {
      _lastText = widget.controller.text;

      widget.onChanged?.call(widget.controller.text);
      _prefixIcon = widget.decoration?.prefixIcons?.call() ?? [];
      _suffixIcon = widget.decoration?.suffixIcons?.call() ?? [];
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

    _focusNode = widget.focusNode ?? FocusNode();

    _prefixIcon = widget.decoration?.prefixIcons?.call() ?? [];
    _suffixIcon = widget.decoration?.suffixIcons?.call() ?? [];
    widget.controller.addListener(_onChangeListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    if (widget.focusNode == null) _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usePrefixIcon = _prefixIcon.isNotEmpty;
    final useSuffixIcon =
        _suffixIcon.isNotEmpty &&
        (widget.decoration?.hideSuffixIconOnEmpty == false ||
            (widget.decoration?.hideSuffixIconOnEmpty == true && widget.controller.text.isNotEmpty));
    return Column(
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            style: widget.style.copyWith(fontSize: (widget.style.fontSize ?? 16)),
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
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
              prefixIcon: usePrefixIcon ? _preSuffix(_prefixIcon) : null,
              suffixIcon: useSuffixIcon ? _preSuffix(_suffixIcon) : null,
              filled: widget.decoration?.filled,
              fillColor: widget.decoration?.fillColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.decoration?.contentHorizontalPadding ?? 12,
                vertical: widget.height != null ? 0 : 16 + (widget.decoration?.contentVerticalPadding ?? 0),
              ),
              enabledBorder:
                  widget.decoration?.enabledBorder ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
              disabledBorder:
                  widget.decoration?.disabledBorder ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
              focusedBorder:
                  widget.decoration?.focusedBorder ??
                  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
            ),
            onTapOutside: (event) => _focusNode.unfocus(),
            onEditingComplete: widget.onEditingComplete,
          ),
        ),
        if (_validateMessage != null)
          SizedBox(
            width: widget.width,
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

  Widget _preSuffix(List<PreSufFixIcon> preSuffixIcons) {
    return SizedBox(
      height: (widget.maxLines ?? 1) > 1 ? (widget.maxLines ?? 1) * 24 : null,
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: widget.decoration?.contentHorizontalPadding ?? 12),
        child: Column(
          mainAxisAlignment: (widget.maxLines ?? 1) > 1 ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < preSuffixIcons.length; i++) ...[
                  if (i != 0) const SizedBox(width: 6),
                  GeneralEffectsButton(
                    onTap: () => preSuffixIcons[i].onTap.call(),
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    color: preSuffixIcons[i].backgroundColor,
                    hoveredColor: preSuffixIcons[i].hoveredColor,
                    splashColor: preSuffixIcons[i].splashColor,
                    borderRadius: BorderRadius.circular(40),
                    child: preSuffixIcons[i].child,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FieldDecoration {
  FieldDecoration({
    this.contentVerticalPadding = 0,
    this.contentHorizontalPadding = 12,
    this.prefixIcons,
    this.suffixIcons,
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
    this.filled = false,
    this.fillColor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
  });

  final double contentVerticalPadding;
  final double contentHorizontalPadding;
  final List<PreSufFixIcon> Function()? prefixIcons;
  final List<PreSufFixIcon> Function()? suffixIcons;
  final bool hideSuffixIconOnEmpty;
  final OutlineInputBorder enabledBorder;
  final OutlineInputBorder disabledBorder;
  final OutlineInputBorder focusedBorder;
  final String? labelText;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior floatingLabelBehavior;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool filled;
  final Color? fillColor;
  final String obscuringCharacter;
  final bool obscureText;
}
