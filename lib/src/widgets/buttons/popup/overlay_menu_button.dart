import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayMenuButton<T> extends StatelessWidget {
  const OverlayMenuButton({
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
    this.menuItemsBorderRadius = 4,
    this.menuItemsPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    required this.menuItems,
    required this.menuItemBuilder,
    required this.onSelected,
    this.onHoverChildBuilder,
    this.child,
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
  final double menuItemsBorderRadius;
  final EdgeInsets? menuItemsPadding;
  final List<T> menuItems;
  final Widget Function(T value) menuItemBuilder;
  final void Function(T value) onSelected;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

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
          itemCount: menuItems.length,
          itemBuilder: (_, index) {
            return GeneralEffectsButton(
              onTap: () {
                onSelected(menuItems[index]);
                closeOverlay();
              },
              padding: menuItemsPadding,
              borderRadius: BorderRadius.circular(menuItemsBorderRadius),
              hoveredColor: Colors.grey.shade300,
              splashColor: Colors.grey.shade400,
              hoverDuration: const Duration(milliseconds: 100),
              child: menuItemBuilder(menuItems[index]),
            );
          },
        ),
      ),
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}
