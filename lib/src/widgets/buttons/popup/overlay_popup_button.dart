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
    this.requestFocusOnHover = false,
    this.closeOnUnHover = false,
    this.closeOnTapOutside = true,
    this.overlayBarrier,
    this.onTap,
    this.onHover,
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
  final bool requestFocusOnHover;
  final bool closeOnUnHover;
  final bool closeOnTapOutside;
  final ModalBarrier? overlayBarrier;
  final void Function(
    void Function({
      required BuildContext context,
      bool dynamicWidth,
      bool slideTransition,
      double? yOffset,
      OverlayAlign alignment,
      OverlayDecoration? decoration,
      required Widget Function(BuildContext context) contentBuilder,
    })
    handleShowOverlay,
    void Function() handleCloseOverlay,
  )?
  onTap;
  final void Function(
    void Function({
      required BuildContext context,
      bool dynamicWidth,
      bool slideTransition,
      double? yOffset,
      OverlayAlign alignment,
      OverlayDecoration? decoration,
      required Widget Function(BuildContext context) contentBuilder,
    })
    handleShowOverlay,
  )?
  onHover;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<OverlayPopupButton> createState() => _OverlayPopupButtonState();
}

class _OverlayPopupButtonState extends State<OverlayPopupButton> {
  final _showOverlay = ShowOverlay.instance;
  final _key = GlobalKey();
  final _layerLink = LayerLink();

  bool _isOverlayContentHovered = false;

  void _onHoverContentInside(bool value) async {
    _isOverlayContentHovered = value;
    await Future.delayed(Duration.zero);
    if (value == false) _showOverlay.remove();
  }

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
        requestFocusOnHover: widget.requestFocusOnHover,
        onTap: () => widget.onTap?.call(({
          required BuildContext context,
          bool dynamicWidth = false,
          bool slideTransition = true,
          double? yOffset,
          OverlayAlign alignment = OverlayAlign.center,
          OverlayDecoration? decoration,
          required Widget Function(BuildContext) contentBuilder,
        }) async {
          _showOverlay.create(
            key: _key,
            linkToTarget: _layerLink,
            context: context,
            dynamicWidth: dynamicWidth,
            slideTransition: slideTransition,
            closeOnTapOutside: widget.closeOnTapOutside,
            barrier: widget.overlayBarrier,
            yOffset: yOffset,
            alignment: alignment,
            decoration: decoration,
            onHoverInside: (value) {
              if (widget.closeOnUnHover) _onHoverContentInside(value);
            },
            contentBuilder: contentBuilder,
          );
        }, () => _showOverlay.remove()),
        onHover: (value) async {
          if (value) {
            widget.onHover?.call(({
              required BuildContext context,
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
                context: context,
                dynamicWidth: dynamicWidth,
                slideTransition: slideTransition,
                closeOnTapOutside: widget.closeOnTapOutside,
                barrier: widget.overlayBarrier,
                yOffset: yOffset,
                alignment: alignment,
                decoration: decoration,
                onHoverInside: (value) {
                  if (widget.closeOnUnHover) _onHoverContentInside(value);
                },
                contentBuilder: contentBuilder,
              );
            });
          } else {
            if (widget.closeOnUnHover) {
              await Future.delayed(Duration.zero);
              if (!_isOverlayContentHovered) _showOverlay.remove();
            }
          }
        },
        onHoverChildBuilder: widget.onHoverChildBuilder,
        child: widget.child,
      ),
    );
  }
}

class DropdownItemDecoration {
  const DropdownItemDecoration({this.padding, this.selectedColor, this.hoveredColor, this.splashColor, this.borderRadius = 0});

  final EdgeInsets? padding;
  final Color? selectedColor;
  final Color? hoveredColor;
  final Color? splashColor;
  final double borderRadius;
}
