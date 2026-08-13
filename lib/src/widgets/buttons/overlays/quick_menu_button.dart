import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class const QuickMenuButton<T>({
  super.key,
  required final void Function(T value) onSelected,
  final QuickButtonStyle buttonStyle = const QuickButtonStyle(
    splashFactory: InkSparkle.splashFactory,
    hoverDuration: Duration(milliseconds: 250),
    elevation: 1,
    hoveredElevationScale: 1,
    requestFocusOnHover: false,
    clipBehavior: .none,
  ),
  final OverlayDecoration overlayDecoration = const .dynamicWidth(
    offsetY: 6,
    offsetX: 8,
    marginY: 14,
    marginX: 14,
    flipOffset: 80,
    padding: .symmetric(vertical: 8),
    color: Color(0xFFFAFAFA),
    borderRadius: 8,
    border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    elevation: 1,
    elevationType: .shadow,
    slideTransition: true,
    useBarrier: false,
  ),
  // this.overlayInstanceType = .singleton,
  final MenuItemDecoration itemDecoration = const MenuItemDecoration(
    padding: .symmetric(horizontal: 10, vertical: 8),
    margin: .symmetric(vertical: 2),
    color: Colors.white,
    hoveredColor: Color(0xFFF5F5F5),
    borderRadius: 0,
  ),
  final bool disabled = false,
  final bool showOnHover = false,
  final bool closeOnUnHover = false,
  required final List<T> items,
  required final Widget Function(BuildContext context, T value) itemBuilder,
  final Widget Function(BuildContext context, bool value)? onHoverChildBuilder,
  final Widget? child,
}) extends StatelessWidget {
  // final OverlayInstanceType overlayInstanceType;
  void _overlay(
    BuildContext context,
    void Function(
      BuildContext, {
      required OverlayDecoration decoration,
      required Widget Function(BuildContext context) contentBuilder,
    })
    showOverlay,
    void Function() closeOverlay,
  ) => showOverlay(
    context,
    decoration: overlayDecoration.copyWith(padding: .zero),
    contentBuilder: (_) => _Menus(
      onSelected: onSelected,
      overlayPadding: overlayDecoration.padding,
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
      overlayInstanceOptionBuilder: (_) => const .singleton(),
      disabled: disabled,
      closeOnUnHover: closeOnUnHover,
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}

class const _Menus<T>({
  required final void Function(T value) onSelected,
  required final EdgeInsets overlayPadding,
  required final MenuItemDecoration decoration,
  required final List<T> items,
  required final Widget Function(BuildContext context, T value) itemBuilder,
  required final void Function() closeOverlay,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemCount = items.length;

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
