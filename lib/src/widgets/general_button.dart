import 'package:quick_dev_sdk/src/widgets/hovered_background.dart';
import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  const GeneralButton({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.hoveredColor,
    this.unhoveredColor,
    this.useInitialBoxShadow = false,
    this.hoveredBoxShadow,
    this.borderRadius,
    this.border,
    this.boxShape,
    this.clipBehavior = Clip.none,
    this.isDisabled = false,
    required this.onTap,
    this.onHover,
    this.onHoverChildBuilder,
    this.child,
  });

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? hoveredColor;
  final Color? unhoveredColor;
  final bool useInitialBoxShadow;
  final BoxShadow? hoveredBoxShadow;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final BoxShape? boxShape;
  final Clip clipBehavior;
  final bool isDisabled;
  final void Function() onTap;
  final void Function(bool value)? onHover;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : () => onTap(),
      child: HoveredBackground(
        width: width,
        height: height,
        padding: padding,
        hoveredColor: hoveredColor,
        unhoveredColor: unhoveredColor,
        useInitialBoxShadow: useInitialBoxShadow,
        hoveredBoxShadow: hoveredBoxShadow,
        borderRadius: borderRadius,
        border: border,
        boxShape: boxShape,
        clipBehavior: clipBehavior,
        cursor:
            isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onHover: (value) => onHover?.call(value),
        onHoverChildBuilder: onHoverChildBuilder,
        child: child,
      ),
    );
  }
}
