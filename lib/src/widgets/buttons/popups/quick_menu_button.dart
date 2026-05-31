import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickMenuButton<T> extends StatelessWidget {
  const QuickMenuButton({
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
    this.overlaydecoration = const .dynamicWidth(
      offsetY: 6,
      offsetX: 8,
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
    this.itemDecoration = const MenuItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      color: Colors.white,
      hoveredColor: Color(0xFFF5F5F5),
      borderRadius: 0,
    ),
    this.disabled = false,
    this.showOnHover = false,
    this.closeOnUnHover = false,
    required this.items,
    required this.itemBuilder,
    this.onHoverChildBuilder,
    this.child,
  });

  final void Function(T value) onSelected;
  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlaydecoration;
  final MenuItemDecoration itemDecoration;
  final bool disabled;
  final bool showOnHover;
  final bool closeOnUnHover;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context, bool value)? onHoverChildBuilder;
  final Widget? child;

  void _overlay(
    BuildContext context,
    void Function(
      BuildContext, {
      required Widget Function(BuildContext, {bool? measuringContentWidth}) contentBuilder,
      required OverlayDecoration decoration,
    })
    showOverlay,
    void Function() closeOverlay,
  ) => showOverlay(
    context,
    decoration: overlaydecoration.copyWith(padding: .zero),
    contentBuilder: (_, {measuringContentWidth}) => _Menus(
      onSelected: onSelected,
      measuringContentWidth: measuringContentWidth,
      overlayPadding: overlaydecoration.padding,
      decoration: itemDecoration,
      items: items,
      itemBuilder: itemBuilder,
      closeOverlay: closeOverlay,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return QuickStickyOverlayButton(
      onTap: (showOverlay, closeOverlay) => _overlay(context, showOverlay, closeOverlay),
      onHover: showOnHover
          ? (showOverlay, closeOverlay) => _overlay(context, showOverlay, closeOverlay)
          : null,
      buttonStyle: buttonStyle,
      disabled: disabled,
      closeOnUnHover: closeOnUnHover,
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}

class _Menus<T> extends StatelessWidget {
  const _Menus({
    required this.onSelected,
    this.measuringContentWidth,
    required this.overlayPadding,
    required this.decoration,
    required this.items,
    required this.itemBuilder,
    required this.closeOverlay,
  });

  final void Function(T value) onSelected;
  final bool? measuringContentWidth;
  final EdgeInsets overlayPadding;
  final MenuItemDecoration decoration;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final void Function() closeOverlay;

  @override
  Widget build(BuildContext context) {
    final itemCount = measuringContentWidth == true ? 1 : items.length;

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
              color: decoration.color,
              hoveredColor: decoration.hoveredColor,
              elevation: 0,
              hoverDuration: const Duration(milliseconds: 100),
            ),
            child: itemBuilder(context, item),
          ),
        );
      },
    );
  }
}
