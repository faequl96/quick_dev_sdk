import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class QuickPopupButton extends StatefulWidget {
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
    this.disabled = false,
    this.closeOnUnHover = false,
    this.closeOnTapOutside = true,
    this.onTap,
    this.onHover,
    this.onHoverChildBuilder,
    this.child,
  });

  final QuickButtonStyle buttonStyle;
  final bool disabled;
  final bool closeOnUnHover;
  final bool closeOnTapOutside;
  final void Function(
    void Function(
      BuildContext context, {
      required OverlayDecoration decoration,
      required Widget Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder,
    })
    handleShowOverlay,
    void Function() handleCloseOverlay,
  )?
  onTap;
  final void Function(
    void Function(
      BuildContext context, {
      required OverlayDecoration decoration,
      required Widget Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder,
    })
    handleShowOverlay,
  )?
  onHover;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<QuickPopupButton> createState() => _QuickPopupButtonState();
}

class _QuickPopupButtonState extends State<QuickPopupButton> {
  final _overlay = StickyOverlay.instance;
  final _key = GlobalKey();
  final _layerLink = LayerLink();

  bool _isOverlayContentHovered = false;

  void _onHoverContentInside(bool value) async {
    _isOverlayContentHovered = value;
    await Future<void>.delayed(.zero);
    if (value == false) _overlay.remove();
  }

  void _handleShowOverlay(
    BuildContext context, {
    required bool closeOnTapTarget,
    required OverlayDecoration decoration,
    required Widget Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder,
  }) {
    _overlay.create(
      context,
      targetKey: _key,
      link: _layerLink,
      closeOnTapOutside: widget.closeOnTapOutside,
      closeOnTapTarget: closeOnTapTarget,
      decoration: decoration,
      onHoverInside: (value) {
        if (widget.closeOnUnHover) _onHoverContentInside(value);
      },
      contentBuilder: contentBuilder,
    );
  }

  @override
  void dispose() {
    _overlay.remove();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: QuickButton(
        key: _key,
        style: widget.buttonStyle,
        disabled: widget.disabled,
        onTap: () => widget.onTap?.call((
          BuildContext context, {
          required OverlayDecoration decoration,
          required Widget Function(BuildContext, {bool? isMeasuringWidth}) contentBuilder,
        }) async {
          _handleShowOverlay(
            context,
            closeOnTapTarget: true,
            decoration: decoration,
            contentBuilder: contentBuilder,
          );
        }, () => _overlay.remove()),
        onHover: (value) async {
          if (value) {
            widget.onHover?.call((
              BuildContext context, {
              required OverlayDecoration decoration,
              required Widget Function(BuildContext, {bool? isMeasuringWidth}) contentBuilder,
            }) {
              _handleShowOverlay(
                context,
                closeOnTapTarget: false,
                decoration: decoration,
                contentBuilder: contentBuilder,
              );
            });
          } else {
            if (widget.closeOnUnHover) {
              await Future<void>.delayed(.zero);
              if (!_isOverlayContentHovered) _overlay.remove();
            }
          }
        },
        onHoverChildBuilder: widget.onHoverChildBuilder,
        child: widget.child,
      ),
    );
  }
}
