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
    this.overlayDynamicWidth = false,
    this.overlayYOffset,
    this.overlayAlignment = .center,
    this.overlaydecoration = const OverlayDecoration(
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      elevation: 1,
      elevationType: .elevation,
      clipBehavior: .none,
    ),
    this.dropdownItemDecoration = const DropdownItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      selectedColor: Color(0xFFE0E0E0),
      hoveredColor: Color(0xFFEEEEEE),
      borderRadius: 0,
    ),
    this.disabled = false,
    required this.value,
    this.valueDisplay,
    required this.dropdownItems,
    required this.dropdownItemBuilder,
    required this.onSelected,
  });

  final double? height;
  final double? width;
  final TextStyle style;
  final FieldDecoration decoration;
  final Color? splashColor;
  final bool overlayDynamicWidth;
  final double? overlayYOffset;
  final OverlayAlign overlayAlignment;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration dropdownItemDecoration;
  final bool disabled;
  final String? value;
  final String? valueDisplay;
  final List<String> dropdownItems;
  final Widget Function(String value) dropdownItemBuilder;
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
          dynamicWidth: widget.overlayDynamicWidth,
          alignment: widget.overlayAlignment,
          decoration: widget.overlaydecoration.copyWith(padding: .zero),
          yOffset: widget.overlayYOffset,
          contentBuilder: (_) => _Dropdowns(
            overlayContentBorderRadius: widget.overlaydecoration.borderRadius,
            overlayPadding: widget.overlaydecoration.padding,
            decoration: widget.dropdownItemDecoration,
            value: widget.value,
            items: widget.dropdownItems,
            dropdownItemBuilder: widget.dropdownItemBuilder,
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
    required this.overlayContentBorderRadius,
    this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.dropdownItemBuilder,
    required this.onSelected,
    required this.closeOverlay,
  });

  final double overlayContentBorderRadius;
  final EdgeInsets? overlayPadding;
  final DropdownItemDecoration decoration;
  final T? value;
  final List<T> items;
  final Widget Function(T value) dropdownItemBuilder;
  final void Function(T value) onSelected;
  final void Function() closeOverlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(overlayContentBorderRadius),
      child: ListView.builder(
        padding: overlayPadding,
        shrinkWrap: true,
        cacheExtent: 2,
        itemCount: items.length,
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
              child: dropdownItemBuilder(items[index]),
            ),
          );
        },
      ),
    );
  }
}
