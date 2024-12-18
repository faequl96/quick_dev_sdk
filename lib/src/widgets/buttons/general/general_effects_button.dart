import 'package:quick_dev_sdk/src/utils/color_converter.dart';
import 'package:flutter/material.dart';

class GeneralEffectsButton extends StatefulWidget {
  const GeneralEffectsButton({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.hoveredColor,
    this.splashColor,
    this.hoverDuration = const Duration(milliseconds: 250),
    this.useInitialElevation = false,
    this.hoveredElevation,
    this.borderRadius,
    this.border,
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
  final Color? color;
  final Color? hoveredColor;
  final Color? splashColor;
  final Duration hoverDuration;
  final bool useInitialElevation;
  final double? hoveredElevation;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Clip clipBehavior;
  final bool isDisabled;
  final void Function() onTap;
  final void Function(bool value)? onHover;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<GeneralEffectsButton> createState() => _GeneralEffectsButtonState();
}

class _GeneralEffectsButtonState extends State<GeneralEffectsButton> {
  void Function(bool value)? _onHoverParent;
  void Function(bool value)? _onHoverChild;

  @override
  Widget build(BuildContext context) {
    final unhoveredColor = (widget.color ?? Colors.transparent);

    return _ExtendedStyle(
      color: widget.color,
      useInitialElevation: widget.useInitialElevation,
      hoveredElevation: widget.hoveredElevation,
      borderRadius: widget.borderRadius,
      rebuild: (onHover) => _onHoverParent = onHover,
      child: InkWell(
        onTap: widget.isDisabled ? () {} : () => widget.onTap(),
        hoverColor:
            widget.hoveredColor ?? ColorConverter.lighten(unhoveredColor, 25),
        splashColor: widget.splashColor ?? widget.color ?? Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: widget.borderRadius,
        hoverDuration: widget.hoverDuration,
        mouseCursor: widget.isDisabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onHover: (value) {
          widget.onHover?.call(value);
          if (widget.useInitialElevation || widget.hoveredElevation != null) {
            _onHoverParent?.call(value);
          }
          if (widget.onHoverChildBuilder != null) _onHoverChild?.call(value);
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: widget.border,
              borderRadius: widget.borderRadius,
            ),
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: _ChildWidget(
                rebuild: (onHover) => _onHoverChild = onHover,
                onHoverChildBuilder: widget.onHoverChildBuilder,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExtendedStyle extends StatefulWidget {
  const _ExtendedStyle({
    this.color,
    this.useInitialElevation = false,
    this.hoveredElevation,
    this.borderRadius,
    this.rebuild,
    this.child,
  });

  final Color? color;
  final bool useInitialElevation;
  final double? hoveredElevation;
  final BorderRadius? borderRadius;
  final void Function(void Function(bool value) onHover)? rebuild;
  final Widget? child;

  @override
  State<_ExtendedStyle> createState() => _ExtendedStyleState();
}

class _ExtendedStyleState extends State<_ExtendedStyle> {
  bool isHovered = false;

  double _elevation() {
    final elevation = widget.hoveredElevation;
    if (elevation != null && isHovered) return elevation;
    if (widget.useInitialElevation) return 1;
    return 0;
  }

  @override
  void initState() {
    widget.rebuild?.call((value) => setState(() => isHovered = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: widget.color ?? Colors.transparent,
      elevation: _elevation(),
      borderRadius: widget.borderRadius,
      clipBehavior: Clip.none,
      child: widget.child,
    );
  }
}

class _ChildWidget extends StatefulWidget {
  const _ChildWidget({this.rebuild, this.onHoverChildBuilder, this.child});

  final void Function(void Function(bool value) onHover)? rebuild;
  final Widget Function(bool value)? onHoverChildBuilder;
  final Widget? child;

  @override
  State<_ChildWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<_ChildWidget> {
  Widget? childHovered;

  @override
  void initState() {
    widget.rebuild?.call((value) => setState(() {
          childHovered = widget.onHoverChildBuilder?.call(value);
        }));

    if (widget.onHoverChildBuilder != null) {
      childHovered = widget.onHoverChildBuilder?.call(false);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return childHovered ?? widget.child ?? const SizedBox.shrink();
  }
}
