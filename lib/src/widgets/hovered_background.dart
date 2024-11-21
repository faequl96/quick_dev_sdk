import 'package:flutter/material.dart';

class HoveredBackground extends StatefulWidget {
  const HoveredBackground({
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
    this.cursor = SystemMouseCursors.basic,
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
  final MouseCursor cursor;
  final void Function(bool value)? onHover;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<HoveredBackground> createState() => _HoveredBackgroundState();
}

class _HoveredBackgroundState extends State<HoveredBackground> {
  bool isHovered = false;

  Widget? childHovered;

  final _initialBoxShadow = const BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 1,
    color: Color.fromARGB(10, 0, 0, 0),
  );

  @override
  void initState() {
    if (widget.onHoverChildBuilder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          childHovered = widget.onHoverChildBuilder?.call(false);
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: widget.border,
        color: isHovered
            ? widget.hoveredColor ?? Colors.transparent
            : widget.unhoveredColor ?? Colors.transparent,
        boxShadow: [
          if (widget.hoveredBoxShadow != null) ...[
            if (isHovered)
              widget.hoveredBoxShadow!
            else ...[if (widget.useInitialBoxShadow) _initialBoxShadow]
          ] else ...[
            if (widget.useInitialBoxShadow) _initialBoxShadow
          ],
        ],
        shape: widget.boxShape ?? BoxShape.rectangle,
      ),
      clipBehavior: widget.clipBehavior,
      child: MouseRegion(
        onEnter: (_) => setState(() {
          widget.onHover?.call(true);
          isHovered = true;
          childHovered = widget.onHoverChildBuilder?.call(true);
        }),
        onExit: (_) => setState(() {
          widget.onHover?.call(false);
          isHovered = false;
          childHovered = widget.onHoverChildBuilder?.call(false);
        }),
        cursor: widget.cursor,
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: childHovered ?? widget.child,
        ),
      ),
    );
  }
}
