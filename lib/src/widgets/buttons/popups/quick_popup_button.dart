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
    this.overlaydecoration = const .dynamicWidth(
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
    this.disabled = false,
    this.showOnHover = false,
    this.closeOnUnHover = false,
    this.closeOnTapOutside = true,
    required this.contentBuilder,
    this.onHoverChildBuilder,
    this.child,
  });

  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlaydecoration;
  final bool disabled;
  final bool showOnHover;
  final bool closeOnUnHover;
  final bool closeOnTapOutside;
  final Widget Function(
    BuildContext context, {
    void Function()? closeOverlay,
    bool? isMeasuringWidth,
  })
  contentBuilder;
  final Widget Function(BuildContext context, bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return QuickStickyOverlayButton(
      onTap: (handleShowOverlay, closeOverlay) => handleShowOverlay(
        context,
        decoration: overlaydecoration,
        contentBuilder: (context, {isMeasuringWidth}) {
          return contentBuilder(
            context,
            isMeasuringWidth: isMeasuringWidth,
            closeOverlay: closeOverlay,
          );
        },
      ),
      onHover: showOnHover
          ? (handleShowOverlay, closeOverlay) => handleShowOverlay(
              context,
              decoration: overlaydecoration,
              contentBuilder: (context, {isMeasuringWidth}) => contentBuilder(
                context,
                isMeasuringWidth: isMeasuringWidth,
                closeOverlay: closeOverlay,
              ),
            )
          : null,
      buttonStyle: buttonStyle,
      disabled: disabled,
      closeOnUnHover: closeOnUnHover,
      closeOnTapOutside: closeOnTapOutside,
      onHoverChildBuilder: onHoverChildBuilder,
      child: child,
    );
  }
}
