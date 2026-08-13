import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class const QuickStickyOverlayButton({
  super.key,
  final void Function(
    void Function(
      BuildContext context, {
      required OverlayDecoration decoration,
      required Widget Function(BuildContext context) contentBuilder,
    })
    showOverlay,
    void Function() closeOverlay,
  )?
  onTap,
  final void Function(
    void Function(
      BuildContext context, {
      required OverlayDecoration decoration,
      required Widget Function(BuildContext context) contentBuilder,
    })
    showOverlay,
    void Function() closeOverlay,
  )?
  onHover,
  final QuickButtonStyle buttonStyle = const QuickButtonStyle(
    splashFactory: InkSparkle.splashFactory,
    hoverDuration: Duration(milliseconds: 250),
    elevation: 1,
    hoveredElevationScale: 1,
    requestFocusOnHover: false,
    clipBehavior: .none,
  ),
  required final OverlayInstanceOption Function(GlobalKey targetKey) overlayInstanceOptionBuilder,
  final bool disabled = false,
  final bool closeOnUnHover = false,
  final bool closeOnTapOutside = true,
  final Widget Function(BuildContext context, bool value)? onHoverChildBuilder,
  final Widget? child,
}) extends StatefulWidget {
  @override
  State<QuickStickyOverlayButton> createState() => _QuickStickyOverlayButtonState();
}

class _QuickStickyOverlayButtonState() extends State<QuickStickyOverlayButton> {
  final _overlay = StickyOverlay.instance;
  final _targetKey = GlobalKey();
  final _layerLink = LayerLink();

  late final OverlayInstanceOption _instanceOption;

  bool _isOverlayContentHovered = false;

  void _onHoverContentInside(bool value) async {
    _isOverlayContentHovered = value;
    await Future<void>.delayed(.zero);
    if (value == false) _overlay.remove(_instanceOption);
  }

  void _showOverlay(
    BuildContext context, {
    required bool closeOnTapTarget,
    required OverlayDecoration decoration,
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    _overlay.create(
      context,
      targetKey: _targetKey,
      link: _layerLink,
      instanceOption: _instanceOption,
      removeOnTapOutside: widget.closeOnTapOutside,
      removeOnTapTarget: closeOnTapTarget,
      decoration: decoration,
      onHoverInside: (value) {
        if (widget.closeOnUnHover) _onHoverContentInside(value);
      },
      contentBuilder: contentBuilder,
    );
  }

  @override
  void initState() {
    super.initState();

    _instanceOption = widget.overlayInstanceOptionBuilder(_targetKey);
  }

  @override
  void dispose() {
    _overlay.remove(_instanceOption);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: QuickButton(
        key: _targetKey,
        onTap: () => widget.onTap?.call((
          BuildContext context, {
          required OverlayDecoration decoration,
          required Widget Function(BuildContext context) contentBuilder,
        }) async {
          _showOverlay(
            context,
            closeOnTapTarget: true,
            decoration: decoration,
            contentBuilder: contentBuilder,
          );
        }, () => _overlay.remove(_instanceOption)),
        onHover: (value) async {
          if (value) {
            widget.onHover?.call((
              BuildContext context, {
              required OverlayDecoration decoration,
              required Widget Function(BuildContext context) contentBuilder,
            }) {
              _showOverlay(
                context,
                closeOnTapTarget: false,
                decoration: decoration,
                contentBuilder: contentBuilder,
              );
            }, () => _overlay.remove(_instanceOption));
          } else {
            if (widget.closeOnUnHover) {
              await Future<void>.delayed(.zero);
              if (!_isOverlayContentHovered) _overlay.remove(_instanceOption);
            }
          }
        },
        style: widget.buttonStyle,
        disabled: widget.disabled,
        onHoverChildBuilder: widget.onHoverChildBuilder,
        child: widget.child,
      ),
    );
  }
}
