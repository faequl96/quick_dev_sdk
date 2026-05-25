import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickDropdownField<T> extends StatefulWidget {
  const QuickDropdownField({
    super.key,
    required this.onSelected,
    this.height,
    this.width,
    this.fieldTextStyle = const TextStyle(fontSize: 16),
    this.fieldSplashColor,
    required this.fieldDecorationBuilder,
    required this.fieldValueBuilder,
    this.overlaydecoration = const .fitToTargetWidth(
      offsetY: 6,
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
      color: Colors.white,
      hoveredColor: Color(0xFFF5F5F5),
      borderRadius: 0,
    ),
    this.disabled = false,
    required this.value,
    required this.items,
    required this.itemBuilder,
  });

  final void Function(T value) onSelected;
  final double? height;
  final double? width;
  final TextStyle fieldTextStyle;
  final Color? fieldSplashColor;
  final FieldDecoration Function(TextEditingController controller, T value) fieldDecorationBuilder;
  final String Function(T value) fieldValueBuilder;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final T value;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;

  @override
  State<QuickDropdownField<T>> createState() => _QuickDropdownFieldState<T>();
}

class _QuickDropdownFieldState<T> extends State<QuickDropdownField<T>> {
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.text = _getDisplayValue();
  }

  @override
  void didUpdateWidget(covariant QuickDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _textEditingController.text = _getDisplayValue();
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  String _getDisplayValue() {
    final currentValue = widget.value;
    if (currentValue == null) return '';
    return widget.fieldValueBuilder(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.fieldDecorationBuilder(_textEditingController, widget.value);

    return QuickStickyOverlayButton(
      onTap: (handleShowOverlay, closeOverlay) {
        if (widget.disabled) return;
        handleShowOverlay(
          context,
          decoration: widget.overlaydecoration.copyWith(padding: .zero),
          contentBuilder: (_, {isMeasuringWidth}) => _Dropdowns(
            onSelected: widget.onSelected,
            isMeasuringWidth: isMeasuringWidth,
            overlayPadding: widget.overlaydecoration.padding,
            decoration: widget.itemDecoration,
            value: widget.value,
            items: widget.items,
            itemBuilder: widget.itemBuilder,
            closeOverlay: closeOverlay,
          ),
        );
      },
      buttonStyle: QuickButtonStyle(
        height: widget.height,
        width: widget.width,
        splashColor: widget.fieldSplashColor,
        borderRadius: decoration.enabledBorder.borderRadius,
        elevation: 0,
      ),
      child: Stack(
        children: [
          QuickTextField(
            controller: _textEditingController,
            height: widget.height,
            width: widget.width,
            enabled: true,
            style: widget.fieldTextStyle,
            decoration: decoration,
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
    required this.onSelected,
    this.isMeasuringWidth,
    this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.closeOverlay,
  });

  final void Function(T value) onSelected;
  final bool? isMeasuringWidth;
  final EdgeInsets? overlayPadding;
  final DropdownItemDecoration decoration;
  final T? value;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final void Function() closeOverlay;

  @override
  Widget build(BuildContext context) {
    final itemCount = isMeasuringWidth == true ? 1 : items.length;

    return ListView.builder(
      scrollCacheExtent: const .pixels(2),
      padding: overlayPadding,
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: decoration.margin,
          child: QuickButton(
            onTap: () {
              closeOverlay();
              onSelected(item);
            },
            style: .lite(
              padding: decoration.padding,
              borderRadius: .circular(decoration.borderRadius),
              color: item == value ? decoration.selectedColor : decoration.color,
              hoveredColor: decoration.hoveredColor,
              hoverDuration: const Duration(milliseconds: 100),
              elevation: 0,
            ),
            child: itemBuilder(context, item),
          ),
        );
      },
    );
  }
}
