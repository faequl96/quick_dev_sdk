import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickMenuButton<T> extends StatelessWidget {
  const QuickMenuButton({
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
    this.itemDecoration = const MenuItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      hoveredColor: Color(0xFFEEEEEE),
      borderRadius: 0,
    ),
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    this.onHoverChildBuilder,
    this.child,
  });

  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlaydecoration;
  final MenuItemDecoration itemDecoration;
  final List<T> items;
  final Widget Function(T value) itemBuilder;
  final void Function(T value) onSelected;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return QuickPopupButton(
      buttonStyle: buttonStyle,
      onTap: (handleShowOverlay, closeOverlay) => handleShowOverlay(
        context,
        decoration: overlaydecoration.copyWith(padding: .zero),
        contentBuilder: (_, {bool? isMeasuringWidth}) => _Menus(
          isMeasuringWidth: isMeasuringWidth,
          overlayPadding: overlaydecoration.padding,
          decoration: itemDecoration,
          items: items,
          itemBuilder: itemBuilder,
          onSelected: onSelected,
          closeOverlay: closeOverlay,
        ),
      ),
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}

class _Menus<T> extends StatelessWidget {
  const _Menus({
    this.isMeasuringWidth,
    required this.overlayPadding,
    required this.decoration,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    required this.closeOverlay,
  });

  final bool? isMeasuringWidth;
  final EdgeInsets overlayPadding;
  final MenuItemDecoration decoration;
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
              color: Colors.white,
              hoveredColor: decoration.hoveredColor,
              elevation: 0,
              hoverDuration: const Duration(milliseconds: 100),
            ),
            child: itemBuilder(items[index]),
          ),
        );
      },
    );
  }
}
