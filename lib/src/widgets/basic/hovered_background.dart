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
  bool _isHovered = false;
  Widget? _childHovered;

  final _initialBoxShadow = const BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 1,
    color: Color.fromARGB(10, 0, 0, 0),
  );

  @override
  Widget build(BuildContext context) {
    _childHovered = widget.onHoverChildBuilder?.call(_isHovered);

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: widget.border,
        color: _isHovered
            ? widget.hoveredColor ?? Colors.transparent
            : widget.unhoveredColor ?? Colors.transparent,
        boxShadow: [
          if (widget.hoveredBoxShadow != null) ...[
            if (_isHovered)
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
          _isHovered = true;
        }),
        onExit: (_) => setState(() {
          widget.onHover?.call(false);
          _isHovered = false;
        }),
        cursor: widget.cursor,
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: _childHovered ?? widget.child,
        ),
      ),
    );
  }
}
