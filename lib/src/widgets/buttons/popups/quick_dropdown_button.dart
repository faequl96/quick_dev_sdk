import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickDropdownButton<T> extends StatelessWidget {
  const QuickDropdownButton({
    super.key,
    required this.onSelected,
    this.buttonStyle = const QuickButtonStyle(
      splashFactory: InkSparkle.splashFactory,
      hoverDuration: Duration(milliseconds: 250),
      elevation: 1,
      hoveredElevationScale: 1,
      requestFocusOnHover: false,
      clipBehavior: .none,
    ),
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
      selectedColor: Color(0xFFE0E0E0),
      borderRadius: 0,
    ),
    this.disabled = false,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.selectedValueBuilder,
  });

  final void Function(T value) onSelected;
  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final T? value;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget? Function(BuildContext context, T? value) selectedValueBuilder;

  @override
  Widget build(BuildContext context) {
    return QuickStickyOverlayButton(
      onTap: (handleShowOverlay, closeOverlay) {
        if (disabled) return;
        handleShowOverlay(
          context,
          decoration: overlaydecoration.copyWith(padding: .zero),
          contentBuilder: (_, {isMeasuringWidth}) => _Dropdowns(
            onSelected: onSelected,
            isMeasuringWidth: isMeasuringWidth,
            overlayPadding: overlaydecoration.padding,
            decoration: itemDecoration,
            value: value,
            items: items,
            itemBuilder: itemBuilder,
            closeOverlay: closeOverlay,
          ),
        );
      },
      buttonStyle: buttonStyle,
      disabled: disabled,
      child: selectedValueBuilder(context, value),
    );
  }
}

class _Dropdowns<T> extends StatelessWidget {
  const _Dropdowns({
    required this.onSelected,
    this.isMeasuringWidth,
    required this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.closeOverlay,
  });

  final void Function(T value) onSelected;
  final bool? isMeasuringWidth;
  final EdgeInsets overlayPadding;
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
