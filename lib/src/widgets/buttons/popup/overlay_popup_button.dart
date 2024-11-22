import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class OverlayPopupButton extends StatefulWidget {
  const OverlayPopupButton({
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
    this.onTap,
    this.onHover,
    this.closeOnTapOutside = true,
    this.closeOnUnHover = false,
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
  final void Function(
    void Function({
      bool dynamicWidth,
      bool slideTransition,
      double? yOffset,
      OverlayAlign alignment,
      OverlayDecoration? decoration,
      required Widget Function(BuildContext context) contentBuilder,
    }) handleShowOverlay,
    void Function() handleCloseOverlay,
  )? onTap;
  final void Function(
    void Function({
      bool dynamicWidth,
      bool slideTransition,
      double? yOffset,
      OverlayAlign alignment,
      OverlayDecoration? decoration,
      required Widget Function(BuildContext context) contentBuilder,
    }) handleShowOverlay,
    void Function() handleCloseOverlay,
  )? onHover;
  final bool closeOnTapOutside;
  final bool closeOnUnHover;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<OverlayPopupButton> createState() => _OverlayPopupButtonState();
}

class _OverlayPopupButtonState extends State<OverlayPopupButton> {
  final ShowOverlay _showOverlay = ShowOverlay.instance;
  final GlobalKey _key = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GeneralEffectsButton(
        key: _key,
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
        isDisabled: widget.onTap == null,
        onTap: () => widget.onTap?.call(
          ({
            bool dynamicWidth = false,
            bool slideTransition = true,
            double? yOffset,
            OverlayAlign alignment = OverlayAlign.center,
            OverlayDecoration? decoration,
            required Widget Function(BuildContext) contentBuilder,
          }) {
            _showOverlay.create(
              key: _key,
              linkToTarget: _layerLink,
              dynamicWidth: dynamicWidth,
              slideTransition: slideTransition,
              closeOnTapOutside: widget.closeOnTapOutside,
              yOffset: yOffset,
              alignment: alignment,
              decoration: decoration,
              contentBuilder: contentBuilder,
            );
          },
          () => _showOverlay.remove(),
        ),
        onHover: (value) {
          if (value) {
            widget.onHover?.call(
              ({
                bool dynamicWidth = false,
                bool slideTransition = true,
                double? yOffset,
                OverlayAlign alignment = OverlayAlign.center,
                OverlayDecoration? decoration,
                required Widget Function(BuildContext) contentBuilder,
              }) {
                _showOverlay.create(
                  key: _key,
                  linkToTarget: _layerLink,
                  dynamicWidth: dynamicWidth,
                  slideTransition: slideTransition,
                  yOffset: yOffset,
                  alignment: alignment,
                  decoration: decoration,
                  closeOnTapOutside: widget.closeOnTapOutside,
                  contentBuilder: contentBuilder,
                );
              },
              () => _showOverlay.remove(),
            );
          } else {
            if (widget.closeOnUnHover) _showOverlay.remove();
          }
        },
        onHoverChildBuilder: widget.onHoverChildBuilder,
        child: widget.child,
      ),
    );
  }
}
