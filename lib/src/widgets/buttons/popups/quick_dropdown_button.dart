import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickDropdownButton<T> extends StatelessWidget {
  const QuickDropdownButton({
    super.key,
    this.buttonStyle = const QuickButtonStyle(
      splashFactory: InkSparkle.splashFactory,
      hoverDuration: Duration(milliseconds: 250),
      elevation: 1,
      hoveredElevationScale: 1,
      clipBehavior: .none,
      requestFocusOnHover: false,
    ),
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
    required this.dropdownItems,
    required this.dropdownItemBuilder,
    required this.onSelected,
    required this.selectedValueBuilder,
  });

  final QuickButtonStyle buttonStyle;
  final bool overlayDynamicWidth;
  final double? overlayYOffset;
  final OverlayAlign overlayAlignment;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration dropdownItemDecoration;
  final bool disabled;
  final T? value;
  final List<T> dropdownItems;
  final Widget Function(T value) dropdownItemBuilder;
  final void Function(T value) onSelected;
  final Widget? Function(T? value) selectedValueBuilder;

  @override
  Widget build(BuildContext context) {
    return QuickPopupButton(
      buttonStyle: buttonStyle,
      onTap: (handleShowOverlay, closeOverlay) {
        if (disabled) return;
        handleShowOverlay(
          context,
          dynamicWidth: overlayDynamicWidth,
          alignment: overlayAlignment,
          decoration: overlaydecoration.copyWith(padding: .zero),
          yOffset: overlayYOffset,
          contentBuilder: (_) => _Dropdowns(
            overlayContentBorderRadius: overlaydecoration.borderRadius,
            overlayPadding: overlaydecoration.padding,
            decoration: dropdownItemDecoration,
            value: value,
            items: dropdownItems,
            dropdownItemBuilder: dropdownItemBuilder,
            onSelected: onSelected,
            closeOverlay: closeOverlay,
          ),
        );
      },
      child: selectedValueBuilder(value),
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
