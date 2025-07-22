import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayMenuButton<T> extends StatelessWidget {
  const OverlayMenuButton({
    super.key,
    this.parenContext,
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
    this.menuItemsPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    required this.menuItems,
    required this.menuItemBuilder,
    required this.onSelected,
    this.onHoverChildBuilder,
    this.child,
  });

  final BuildContext? parenContext;
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
        context: parenContext ?? context,
        dynamicWidth: overlayDynamicWidth,
        alignment: overlayAlignment,
        decoration: overlaydecoration?.copyWith(padding: EdgeInsets.zero),
        yOffset: overlayYOffset,
        contentBuilder: (_) => _Menus(
          menuItemsBorderRadius: menuItemsBorderRadius,
          menuItemsPadding: menuItemsPadding,
          overlayPadding: overlaydecoration?.padding,
          items: menuItems,
          menuItemBuilder: menuItemBuilder,
          onSelected: onSelected,
          closeOverlay: closeOverlay,
        ),
      ),
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}

class _Menus<T> extends StatefulWidget {
  const _Menus({
    required this.menuItemsBorderRadius,
    this.menuItemsPadding,
    this.overlayPadding,
    required this.items,
    required this.menuItemBuilder,
    required this.onSelected,
    required this.closeOverlay,
  });

  final double menuItemsBorderRadius;
  final EdgeInsets? menuItemsPadding;
  final EdgeInsets? overlayPadding;
  final List<T> items;
  final Widget Function(T value) menuItemBuilder;
  final void Function(T value) onSelected;
  final void Function() closeOverlay;

  @override
  State<_Menus<T>> createState() => _MenusState<T>();
}

class _MenusState<T> extends State<_Menus<T>> {
  final _listViewKey = GlobalKey();
  double? _listViewHeight;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listViewHeight = (_listViewKey.currentContext?.size?.height ?? 0) + 2;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _listViewHeight,
      child: ListView.builder(
        key: _listViewKey,
        padding: widget.overlayPadding,
        shrinkWrap: true,
        cacheExtent: 10,
        itemCount: widget.items.length,
        itemBuilder: (_, index) {
          return GeneralEffectsButton(
            onTap: () {
              widget.onSelected(widget.items[index]);
              widget.closeOverlay();
            },
            padding: widget.menuItemsPadding,
            borderRadius: BorderRadius.circular(widget.menuItemsBorderRadius),
            hoveredColor: Colors.grey.shade300,
            splashColor: Colors.grey.shade400,
            hoverDuration: const Duration(milliseconds: 100),
            child: widget.menuItemBuilder(widget.items[index]),
          );
        },
      ),
    );
  }
}
