import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class QuickPopupButton extends StatelessWidget {
  const QuickPopupButton({
    super.key,
    this.buttonStyle = const QuickButtonStyle(
      splashFactory: InkSparkle.splashFactory,
      hoverDuration: Duration(milliseconds: 250),
      elevation: 1,
      hoveredElevationScale: 1,
      requestFocusOnHover: false,
      clipBehavior: .none,
    ),
    this.overlayDecoration = const .dynamicWidth(
      offsetY: 6,
      offsetX: 8,
      marginY: 14,
      marginX: 14,
      flipOffset: 80,
      padding: .zero,
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
      useBarrier: false,
    ),
    required this.overlayInstanceOptionBuilder,
    this.disabled = false,
    this.showOnHover = false,
    this.closeOnUnHover = false,
    this.closeOnTapOutside = true,
    required this.contentBuilder,
    this.onHoverChildBuilder,
    this.child,
  });

  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlayDecoration;
  final OverlayInstanceOption Function(GlobalKey targetKey) overlayInstanceOptionBuilder;
  final bool disabled;
  final bool showOnHover;
  final bool closeOnUnHover;
  final bool closeOnTapOutside;
  final Widget Function(BuildContext context, {void Function()? closeOverlay}) contentBuilder;
  final Widget Function(BuildContext context, bool value)? onHoverChildBuilder;
  final Widget? child;

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
    decoration: overlayDecoration,
    contentBuilder: (context) => contentBuilder(context, closeOverlay: closeOverlay),
  );

  @override
  Widget build(BuildContext context) {
    return QuickStickyOverlayButton(
      onTap: (showOverlay, closeOverlay) => _overlay(context, showOverlay, closeOverlay),
      onHover: showOnHover
          ? (showOverlay, closeOverlay) => _overlay(context, showOverlay, closeOverlay)
          : null,
      buttonStyle: buttonStyle,
      overlayInstanceOptionBuilder: overlayInstanceOptionBuilder,
      disabled: disabled,
      closeOnUnHover: closeOnUnHover,
      closeOnTapOutside: closeOnTapOutside,
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}
