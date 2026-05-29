import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickTextField extends StatefulWidget {
  const QuickTextField({
    super.key,
    this.height,
    this.width,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled,
    this.readOnly = false,
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
  final bool readOnly;
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
  State<QuickTextField> createState() => _QuickTextFieldState();
}

class _QuickTextFieldState extends State<QuickTextField> {
  late final FocusNode _focusNode;
  bool _isLocalFocusNode = false;

  Widget? _validateMessage;
  List<PreSufFixIcon> _prefixIcon = [];
  List<PreSufFixIcon> _suffixIcon = [];

  String _lastText = '';

  void _onChangeListener() {
    if (widget.controller.text != _lastText) {
      _lastText = widget.controller.text;

      widget.onChanged?.call(widget.controller.text);
      _prefixIcon = widget.decoration?.prefixIcons?.call(widget.controller) ?? [];
      _suffixIcon = widget.decoration?.suffixIcons?.call(widget.controller) ?? [];

      if (widget.validator != null) {
        final validate = widget.validator!.call(_lastText);
        final newMsg = (validate.isSuccess == false) ? validate.message : null;
        if (_validateMessage != newMsg) _validateMessage = newMsg;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _lastText = widget.controller.text;

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _isLocalFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _prefixIcon = widget.decoration?.prefixIcons?.call(widget.controller) ?? [];
    _suffixIcon = widget.decoration?.suffixIcons?.call(widget.controller) ?? [];
    widget.controller.addListener(_onChangeListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    if (_isLocalFocusNode) _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usePrefixIcon = _prefixIcon.isNotEmpty;
    final useSuffixIcon =
        _suffixIcon.isNotEmpty &&
        (widget.decoration?.hideSuffixIconOnEmpty == false ||
            (widget.decoration?.hideSuffixIconOnEmpty == true &&
                widget.controller.text.isNotEmpty));

    final defaultBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26),
      borderRadius: .all(.circular(8)),
    );

    return Column(
      mainAxisSize: .min,
      children: [
        Flexible(
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              style: widget.style.copyWith(fontSize: (widget.style.fontSize ?? 16)),
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              expands: widget.maxLines == null ? true : false,
              obscureText: widget.decoration?.obscureText ?? false,
              obscuringCharacter: widget.decoration?.obscuringCharacter ?? '•',
              cursorHeight: (widget.style.fontSize ?? 16) + 10,
              decoration: InputDecoration(
                labelText: widget.decoration?.labelText,
                labelStyle: widget.decoration?.labelStyle,
                // floatingLabelStyle: widget.decoration?.labelStyle,
                floatingLabelBehavior: widget.decoration?.floatingLabelBehavior,
                hintText: widget.decoration?.hintText,
                hintStyle: widget.decoration?.hintStyle,
                prefixIcon: usePrefixIcon ? _preSuffix(_prefixIcon) : null,
                suffixIcon: useSuffixIcon ? _preSuffix(_suffixIcon) : null,
                filled: widget.decoration?.filled,
                fillColor: widget.decoration?.fillColor,
                counterText: '',
                contentPadding: .symmetric(
                  horizontal: widget.decoration?.contentHorizontalPadding ?? 12,
                  vertical: widget.height != null
                      ? 0
                      : 16 + (widget.decoration?.contentVerticalPadding ?? 0),
                ),
                enabledBorder: widget.decoration?.enabledBorder ?? defaultBorder,
                disabledBorder: widget.decoration?.disabledBorder ?? defaultBorder,
                focusedBorder: widget.decoration?.focusedBorder ?? defaultBorder,
              ),
              onTapOutside: (event) => _focusNode.unfocus(),
              onEditingComplete: widget.onEditingComplete,
            ),
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
        padding: .only(left: 8, right: widget.decoration?.contentHorizontalPadding ?? 12),
        child: Column(
          mainAxisAlignment: (widget.maxLines ?? 1) > 1 ? .start : .center,
          children: [
            Row(
              mainAxisSize: .min,
              children: [
                for (int i = 0; i < preSuffixIcons.length; i++) ...[
                  if (i != 0) const SizedBox(width: 6),
                  QuickButton(
                    onTap: () => preSuffixIcons[i].onTap.call(),
                    style: QuickButtonStyle(
                      padding: const .symmetric(horizontal: 2, vertical: 2),
                      color: preSuffixIcons[i].backgroundColor,
                      hoveredColor: preSuffixIcons[i].hoveredColor,
                      splashColor: preSuffixIcons[i].splashColor,
                      borderRadius: .circular(40),
                    ),
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
  const FieldDecoration({
    this.contentVerticalPadding = 0,
    this.contentHorizontalPadding = 12,
    this.prefixIcons,
    this.suffixIcons,
    this.hideSuffixIconOnEmpty = false,
    this.enabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
      borderRadius: .all(.circular(8)),
    ),
    this.disabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
      borderRadius: .all(.circular(8)),
    ),
    this.focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
      borderRadius: .all(.circular(8)),
    ),
    this.labelText,
    this.labelStyle,
    this.floatingLabelBehavior = .auto,
    this.hintText,
    this.hintStyle,
    this.filled = false,
    this.fillColor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
  });

  final double contentVerticalPadding;
  final double contentHorizontalPadding;
  final List<PreSufFixIcon> Function(TextEditingController controller)? prefixIcons;
  final List<PreSufFixIcon> Function(TextEditingController controller)? suffixIcons;
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

  FieldDecoration copyWith({
    double? contentVerticalPadding,
    double? contentHorizontalPadding,
    List<PreSufFixIcon> Function(TextEditingController controller)? prefixIcons,
    List<PreSufFixIcon> Function(TextEditingController controller)? suffixIcons,
    bool? hideSuffixIconOnEmpty,
    OutlineInputBorder? enabledBorder,
    OutlineInputBorder? disabledBorder,
    OutlineInputBorder? focusedBorder,
    String? labelText,
    TextStyle? labelStyle,
    FloatingLabelBehavior? floatingLabelBehavior,
    String? hintText,
    TextStyle? hintStyle,
    bool? filled,
    Color? fillColor,
    String? obscuringCharacter,
    bool? obscureText,
  }) {
    return FieldDecoration(
      contentVerticalPadding: contentVerticalPadding ?? this.contentVerticalPadding,
      contentHorizontalPadding: contentHorizontalPadding ?? this.contentHorizontalPadding,
      prefixIcons: prefixIcons ?? this.prefixIcons,
      suffixIcons: suffixIcons ?? this.suffixIcons,
      hideSuffixIconOnEmpty: hideSuffixIconOnEmpty ?? this.hideSuffixIconOnEmpty,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      floatingLabelBehavior: floatingLabelBehavior ?? this.floatingLabelBehavior,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      obscureText: obscureText ?? this.obscureText,
    );
  }
}
