import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayMenuButton<T> extends StatefulWidget {
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
  State<OverlayMenuButton<T>> createState() => _OverlayMenuButtonState<T>();
}

class _OverlayMenuButtonState<T> extends State<OverlayMenuButton<T>> {
  @override
  Widget build(BuildContext context) {
    return OverlayPopupButton(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      color: widget.color,
      hoveredColor: widget.hoveredColor,
      splashColor: widget.splashColor,
      useInitialElevation: widget.useInitialElevation,
      hoveredElevation: widget.hoveredElevation,
      borderRadius: widget.borderRadius,
      border: widget.border,
      clipBehavior: widget.clipBehavior,
      onTap: (handleShowOverlay, _) => handleShowOverlay(
        dynamicWidth: widget.overlayDynamicWidth,
        alignment: widget.overlayAlignment,
        decoration: widget.overlaydecoration,
        yOffset: widget.overlayYOffset,
        contentBuilder: (_) => ListView.builder(
          shrinkWrap: true,
          itemCount: widget.menuItems.length,
          itemBuilder: (_, index) {
            return GeneralEffectsButton(
              onTap: () => widget.onSelected(widget.menuItems[index]),
              padding: widget.menuItemsPadding,
              borderRadius: BorderRadius.circular(widget.menuItemsBorderRadius),
              hoveredColor: Colors.grey.shade300,
              splashColor: Colors.grey.shade400,
              hoverDuration: const Duration(milliseconds: 100),
              child: widget.menuItemBuilder(widget.menuItems[index]),
            );
          },
        ),
      ),
      onHoverChildBuilder: widget.onHoverChildBuilder,
      child: widget.child,
    );
  }
}
