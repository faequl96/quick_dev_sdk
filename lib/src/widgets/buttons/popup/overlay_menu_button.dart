import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayMenuButton extends StatefulWidget {
  const OverlayMenuButton({
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
    this.overlayAlignment = OverlayAlign.center,
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
  final OverlayAlign overlayAlignment;

  @override
  State<OverlayMenuButton> createState() => _OverlayMenuButtonState();
}

class _OverlayMenuButtonState extends State<OverlayMenuButton> {
  @override
  Widget build(BuildContext context) {
    return OverlayPopupButton(
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
      closeOnUnHover: true,
      onTap: (handleShowOverlay, _) => handleShowOverlay(
        dynamicWidth: true,
        alignment: widget.overlayAlignment,
        decoration: OverlayDecoration(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        yOffset: 10,
        contentBuilder: (context) => const Column(
          children: [
            Text("Test Overlay Button"),
            Text("Test Overlay Button"),
            Text("Test Overlay Button"),
            Text("Test Overlay Button"),
            Text("Test Overlay Button"),
          ],
        ),
      ),
      onHoverChildBuilder: (value) {
        return const Icon(Icons.more_vert);
      },
    );
  }
}
