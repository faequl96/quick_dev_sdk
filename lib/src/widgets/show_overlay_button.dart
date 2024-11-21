import 'package:quick_dev_sdk/src/popups/show_overlay.dart';
import 'package:quick_dev_sdk/src/widgets/general_button.dart';
import 'package:flutter/material.dart';

class ShowOverlayButton extends StatefulWidget {
  const ShowOverlayButton({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.hoveredColor,
    this.unhoveredColor,
    this.useInitialBoxShadow = false,
    this.hoveredBoxShadow,
    this.borderRadius,
    this.border,
    this.boxShape,
    this.clipBehavior = Clip.none,
    this.isDisabled,
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
  final EdgeInsets? margin;
  final Color? hoveredColor;
  final Color? unhoveredColor;
  final bool useInitialBoxShadow;
  final BoxShadow? hoveredBoxShadow;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final BoxShape? boxShape;
  final Clip clipBehavior;
  final bool? isDisabled;
  final void Function(
    void Function({
      bool dynamicWidth,
      bool slideTransition,
      Offset? offset,
      OverlayDecoration? decoration,
      required Widget Function(BuildContext context) contentBuilder,
    }) handleShowOverlay,
    void Function() handleCloseOverlay,
  )? onTap;
  final void Function(
    void Function({
      bool dynamicWidth,
      bool slideTransition,
      Offset? offset,
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
  State<ShowOverlayButton> createState() => _ShowOverlayButtonState();
}

class _ShowOverlayButtonState extends State<ShowOverlayButton> {
  final ShowOverlay _showOverlay = ShowOverlay.instance;
  final GlobalKey _key = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GeneralButton(
        key: _key,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        hoveredColor: widget.hoveredColor,
        unhoveredColor: widget.unhoveredColor,
        useInitialBoxShadow: widget.useInitialBoxShadow,
        hoveredBoxShadow: widget.hoveredBoxShadow,
        borderRadius: widget.borderRadius,
        border: widget.border,
        boxShape: widget.boxShape,
        clipBehavior: widget.clipBehavior,
        isDisabled: widget.isDisabled == true || widget.onTap == null,
        onTap: () => widget.onTap?.call(
          ({
            bool dynamicWidth = false,
            bool slideTransition = true,
            Offset? offset,
            OverlayDecoration? decoration,
            required Widget Function(BuildContext) contentBuilder,
          }) {
            _showOverlay.create(
              key: _key,
              linkToTarget: _layerLink,
              dynamicWidth: dynamicWidth,
              slideTransition: slideTransition,
              closeOnTapOutside: widget.closeOnTapOutside,
              offset: offset,
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
                Offset? offset,
                OverlayDecoration? decoration,
                required Widget Function(BuildContext) contentBuilder,
              }) {
                _showOverlay.create(
                  key: _key,
                  linkToTarget: _layerLink,
                  dynamicWidth: dynamicWidth,
                  slideTransition: slideTransition,
                  offset: offset,
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
