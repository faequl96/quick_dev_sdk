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
    this.overlaydecoration = const .fitToTargetWidth(
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
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    required this.selectedValueBuilder,
  });

  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final T? value;
  final List<T> items;
  final Widget Function(T value) itemBuilder;
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
          decoration: overlaydecoration.copyWith(padding: .zero),
          contentBuilder: (_, {bool? isMeasuringWidth}) => _Dropdowns(
            isMeasuringWidth: isMeasuringWidth,
            overlayPadding: overlaydecoration.padding,
            decoration: itemDecoration,
            value: value,
            items: items,
            itemBuilder: itemBuilder,
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
      scrollCacheExtent: const .pixels(2),
      padding: overlayPadding,
      shrinkWrap: true,
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
