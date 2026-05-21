import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickDropdownField extends StatefulWidget {
  const QuickDropdownField({
    super.key,
    this.height,
    this.width,
    this.style = const TextStyle(fontSize: 16),
    this.decoration = const FieldDecoration(
      contentVerticalPadding: 0,
      contentHorizontalPadding: 12,
      hideSuffixIconOnEmpty: false,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
        borderRadius: .all(.circular(8)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
        borderRadius: .all(.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
        borderRadius: .all(.circular(8)),
      ),
      floatingLabelBehavior: .auto,
      filled: false,
      obscuringCharacter: '•',
      obscureText: false,
    ),
    this.splashColor,
    this.overlaydecoration = const OverlayDecoration.fitToTargetWidth(
      yOffset: 6,
      marginY: 14,
      marginX: 14,
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
    ),
    this.itemDecoration = const DropdownItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      selectedColor: Color(0xFFE0E0E0),
      hoveredColor: Color(0xFFEEEEEE),
      borderRadius: 0,
    ),
    this.disabled = false,
    required this.value,
    this.valueDisplay,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
  });

  final double? height;
  final double? width;
  final TextStyle style;
  final FieldDecoration decoration;
  final Color? splashColor;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final String? value;
  final String? valueDisplay;
  final List<String> items;
  final Widget Function(String value) itemBuilder;
  final void Function(String value) onSelected;

  @override
  State<QuickDropdownField> createState() => _QuickDropdownFieldState();
}

class _QuickDropdownFieldState extends State<QuickDropdownField> {
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.text = widget.valueDisplay ?? widget.value ?? '';
  }

  @override
  void didUpdateWidget(covariant QuickDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);

    _textEditingController.text = widget.valueDisplay ?? widget.value ?? '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuickPopupButton(
      buttonStyle: QuickButtonStyle(
        height: widget.height,
        width: widget.width,
        splashColor: widget.splashColor,
        borderRadius: widget.decoration.enabledBorder.borderRadius,
        elevation: 0,
      ),
      onTap: (handleShowOverlay, closeOverlay) {
        if (widget.disabled) return;
        handleShowOverlay(
          context,
          decoration: widget.overlaydecoration.copyWith(padding: .zero),
          contentBuilder: (_, {bool? isMeasuringWidth}) => _Dropdowns(
            isMeasuringWidth: isMeasuringWidth,
            overlayPadding: widget.overlaydecoration.padding,
            decoration: widget.itemDecoration,
            value: widget.value,
            items: widget.items,
            itemBuilder: widget.itemBuilder,
            onSelected: widget.onSelected,
            closeOverlay: closeOverlay,
          ),
        );
      },
      child: Stack(
        children: [
          QuickTextField(
            controller: _textEditingController,
            height: widget.height,
            width: widget.width,
            enabled: false,
            style: widget.style,
            decoration: widget.decoration,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(height: widget.height, width: widget.width),
          ),
        ],
      ),
    );
  }
}

class _Dropdowns<T> extends StatelessWidget {
  const _Dropdowns({
    this.isMeasuringWidth,
    this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    required this.closeOverlay,
  });

  final bool? isMeasuringWidth;
  final EdgeInsets? overlayPadding;
  final DropdownItemDecoration decoration;
  final T? value;
  final List<T> items;
  final Widget Function(T value) itemBuilder;
  final void Function(T value) onSelected;
  final void Function() closeOverlay;

  @override
  Widget build(BuildContext context) {
    final itemCount = isMeasuringWidth == true ? 1 : items.length;

    return ListView.builder(
      padding: overlayPadding,
      shrinkWrap: true,
      cacheExtent: 2,
      itemCount: itemCount,
      itemBuilder: (_, index) {
        return Padding(
          padding: decoration.margin,
          child: QuickButton(
            onTap: () async {
              // await Future<void>.delayed(const Duration(milliseconds: 120));
              closeOverlay();
              onSelected(items[index]);
            },
            style: QuickButtonStyle.lite(
              padding: decoration.padding,
              borderRadius: .circular(decoration.borderRadius),
              color: items[index] == value ? decoration.selectedColor : Colors.white,
              hoveredColor: decoration.hoveredColor,
              hoverDuration: const Duration(milliseconds: 100),
              elevation: 0,
            ),
            child: itemBuilder(items[index]),
          ),
        );
      },
    );
  }
}
