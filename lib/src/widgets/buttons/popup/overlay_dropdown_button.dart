import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayDropdownButton<T> extends StatelessWidget {
  const OverlayDropdownButton({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.hoveredColor,
    this.splashColor,
    this.useInitialElevation = false,
    this.hoveredElevation,
    this.borderRadius,
    this.border,
    this.clipBehavior = Clip.none,
    this.overlayDynamicWidth = false,
    this.overlayYOffset,
    this.overlayAlignment = OverlayAlign.center,
    this.overlaydecoration,
    this.dropdownItemsBorderRadius = 4,
    this.dropdownItemsPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    required this.value,
    required this.dropdownItems,
    required this.dropdownItemBuilder,
    required this.onSelected,
    required this.selectedValueBuilder,
  });

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? color;
  final Color? hoveredColor;
  final Color? splashColor;
  final bool useInitialElevation;
  final double? hoveredElevation;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Clip clipBehavior;
  final bool overlayDynamicWidth;
  final double? overlayYOffset;
  final OverlayAlign overlayAlignment;
  final OverlayDecoration? overlaydecoration;
  final double dropdownItemsBorderRadius;
  final EdgeInsets? dropdownItemsPadding;
  final T? value;
  final List<T> dropdownItems;
  final Widget Function(T value) dropdownItemBuilder;
  final void Function(T value) onSelected;
  final Widget? Function(T? value) selectedValueBuilder;

  @override
  Widget build(BuildContext context) {
    return OverlayPopupButton(
      width: width,
      height: height,
      padding: padding,
      color: color,
      hoveredColor: hoveredColor,
      splashColor: splashColor,
      useInitialElevation: useInitialElevation,
      hoveredElevation: hoveredElevation,
      borderRadius: borderRadius,
      border: border,
      clipBehavior: clipBehavior,
      onTap: (handleShowOverlay, closeOverlay) => handleShowOverlay(
        dynamicWidth: overlayDynamicWidth,
        alignment: overlayAlignment,
        decoration: overlaydecoration,
        yOffset: overlayYOffset,
        contentBuilder: (_) => ListView.builder(
          shrinkWrap: true,
          itemCount: dropdownItems.length,
          itemBuilder: (_, index) {
            return GeneralEffectsButton(
              onTap: () {
                onSelected(dropdownItems[index]);
                closeOverlay();
              },
              padding: dropdownItemsPadding,
              borderRadius: BorderRadius.circular(
                dropdownItemsBorderRadius,
              ),
              hoveredColor: Colors.grey.shade300,
              splashColor: Colors.grey.shade400,
              hoverDuration: const Duration(milliseconds: 100),
              child: dropdownItemBuilder(dropdownItems[index]),
            );
          },
        ),
      ),
      child: selectedValueBuilder(value),
    );
  }
}
