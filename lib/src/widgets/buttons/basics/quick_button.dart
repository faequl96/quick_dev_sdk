import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class QuickButtonStyle {
  const QuickButtonStyle({
    this.width,
    this.height,
    this.padding,
    this.color,
    this.hoveredColor,
    this.splashColor,
    this.splashFactory = InkSparkle.splashFactory,
    this.hoverDuration = const Duration(milliseconds: 250),
    this.elevation = 1,
    this.hoveredElevationScale = 3,
    this.borderRadius,
    this.border,
    this.requestFocusOnHover = false,
    this.clipBehavior = .none,
  }) : isLite = false,
       elevationType = .elevation;

  const QuickButtonStyle.lite({
    this.width,
    this.height,
    this.padding,
    this.color,
    this.hoveredColor,
    this.hoverDuration = const Duration(milliseconds: 150),
    this.elevation = 1,
    this.hoveredElevationScale = 3,
    this.elevationType = .elevation,
    this.borderRadius,
    this.border,
    this.clipBehavior = .none,
  }) : isLite = true,
       splashColor = null,
       splashFactory = InkSparkle.splashFactory,
       requestFocusOnHover = false;

  final bool isLite;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? color;
  final Color? hoveredColor;
  final Color? splashColor;
  final InteractiveInkFeatureFactory splashFactory;
  final Duration hoverDuration;
  final double elevation;
  final double hoveredElevationScale;
  final ElevationType elevationType;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final bool requestFocusOnHover;
  final Clip clipBehavior;
}

class QuickButton extends StatefulWidget {
  const QuickButton({
    super.key,
    required this.onTap,
    this.onHover,
    this.style = const QuickButtonStyle(
      hoverDuration: Duration(milliseconds: 250),
      elevation: 1,
      hoveredElevationScale: 3,
      requestFocusOnHover: false,
    ),
    this.disabled = false,
    this.onHoverChildBuilder,
    this.child,
  });

  final void Function() onTap;
  final void Function(bool value)? onHover;
  final QuickButtonStyle style;
  final bool disabled;
  final Widget Function(BuildContext context, bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<QuickButton> createState() => _QuickButtonState();
}

class _QuickButtonState extends State<QuickButton> {
  FocusNode? _internalFocusNode;
  FocusNode? get _focusNode => _internalFocusNode ??= FocusNode();

  bool _isHovered = false;

  @override
  void dispose() {
    _internalFocusNode?.dispose();

    super.dispose();
  }

  void _handleHover(bool value) {
    if (widget.disabled || _isHovered == value || !mounted) return;
    setState(() => _isHovered = value);
    widget.onHover?.call(value);

    if (!widget.style.isLite && widget.style.requestFocusOnHover == true) {
      if (value) {
        _focusNode?.requestFocus();
      } else {
        _focusNode?.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    if (style.isLite) {
      final color = style.color;
      final bgColor = widget.disabled
          ? Colors.grey.shade400
          : !_isHovered
          ? color
          : style.hoveredColor ?? (color != null ? ColorUtil.lighten(color, 20) : null);
      final elevation = _isHovered
          ? (style.elevation * style.hoveredElevationScale)
          : style.elevation;

      return MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        cursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: _isHovered ? style.hoverDuration : .zero,
            width: style.width,
            height: style.height,
            padding: style.padding ?? .zero,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: style.borderRadius,
              border: style.border,
              boxShadow: !widget.disabled
                  ? DecorationUtils.elevation(elevation, elevationType: style.elevationType)
                  : null,
            ),
            clipBehavior: style.clipBehavior,
            child: widget.onHoverChildBuilder?.call(context, _isHovered) ?? widget.child,
          ),
        ),
      );
    }

    final color = style.color;
    final elevation = _isHovered
        ? (style.elevation * style.hoveredElevationScale)
        : style.elevation;

    return Material(
      type: color != null ? .canvas : .transparency,
      color: widget.disabled ? Colors.grey.shade400 : style.color,
      elevation: widget.disabled ? 0 : elevation,
      borderRadius: style.borderRadius,
      clipBehavior: style.clipBehavior,
      child: InkWell(
        onTap: widget.disabled ? null : widget.onTap,
        onHover: (value) => _handleHover(value),
        focusNode: _focusNode,
        hoverColor:
            style.hoveredColor ??
            (color != null ? ColorUtil.lighten(color, 25) : Colors.transparent),
        splashColor: style.splashColor ?? color,
        splashFactory: style.splashFactory,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: style.borderRadius,
        hoverDuration: style.hoverDuration,
        mouseCursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: SizedBox(
          width: style.width,
          height: style.height,
          child: DecoratedBox(
            decoration: BoxDecoration(border: style.border, borderRadius: style.borderRadius),
            child: Padding(
              padding: style.padding ?? .zero,
              child: widget.onHoverChildBuilder?.call(context, _isHovered) ?? widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
