import 'dart:developer' as dev;
import 'dart:math';

import 'package:quick_dev_sdk/src/widgets/basic/card_container.dart';
import 'package:flutter/material.dart';

class ShowOverlay {
  ShowOverlay._();

  static final ShowOverlay _instance = ShowOverlay._();
  static ShowOverlay get instance => _instance;

  OverlayEntry? _overlayEntry;

  late BuildContext _context;

  Alignment _getAlignment(OverlayAlign alignment) => {
        OverlayAlign.left: Alignment.topLeft,
        OverlayAlign.center: Alignment.topCenter,
        OverlayAlign.right: Alignment.topRight,
      }[alignment]!;

  double _getAlignOffset(OverlayAlign alignment) => {
        OverlayAlign.left: -14.0,
        OverlayAlign.center: 0.0,
        OverlayAlign.right: 14.0,
      }[alignment]!;

  double _getMaxWidth({
    required OverlayAlign alignment,
    required Size size,
    required Size buttonSize,
    required Offset position,
  }) {
    double leftRemainder = position.dx;
    double rightRemainder = size.width - (position.dx + buttonSize.width);
    double minNumber = min(leftRemainder, rightRemainder);
    return {
      OverlayAlign.left: (rightRemainder + buttonSize.width) - 14,
      OverlayAlign.center: (minNumber * 2 + buttonSize.width) - 28,
      OverlayAlign.right: (leftRemainder + buttonSize.width) - 14,
    }[alignment]!;
  }

  void create({
    required GlobalKey key,
    required LayerLink linkToTarget,
    bool dynamicWidth = false,
    bool slideTransition = true,
    bool closeOnTapOutside = true,
    double? yOffset,
    OverlayAlign alignment = OverlayAlign.center,
    OverlayDecoration? decoration,
    void Function(bool value)? onHoverInside,
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    _removePreviousOverlay();

    if (key.currentContext != null) _context = key.currentContext!;
    if (_context.mounted == false) {
      dev.log(
        'Your key is not associated with any widget "ShowOverlay.of(GlobalKey key)"',
      );
      return;
    }

    final size = MediaQuery.of(_context).size;

    final renderBox = _context.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final align = _getAlignment(alignment);
    final maxWidth = _getMaxWidth(
      alignment: alignment,
      size: size,
      buttonSize: buttonSize,
      position: position,
    );
    final maxHeight =
        (size.height - (position.dy + buttonSize.height + (yOffset ?? 0))) - 14;

    _overlayEntry = OverlayEntry(builder: (_) {
      return Stack(children: [
        Positioned(
          width: dynamicWidth ? null : (buttonSize.width + 28),
          child: CompositedTransformFollower(
            link: linkToTarget,
            showWhenUnlinked: false,
            offset: Offset(_getAlignOffset(alignment), buttonSize.height),
            targetAnchor: align,
            followerAnchor: align,
            child: Material(
              type: MaterialType.transparency,
              child: TapRegion(
                onTapOutside: closeOnTapOutside ? (_) => remove() : null,
                child: _OverlayContent(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  yOffset: yOffset,
                  slideTransition: slideTransition,
                  dynamicWidth: dynamicWidth,
                  decoration: decoration,
                  onHoverInside: onHoverInside,
                  child: contentBuilder(_context),
                ),
              ),
            ),
          ),
        ),
      ]);
    });

    Overlay.of(_context).insert(_overlayEntry!);
  }

  void _removePreviousOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void remove() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }
}

class _OverlayContent extends StatefulWidget {
  const _OverlayContent({
    required this.maxWidth,
    required this.maxHeight,
    this.yOffset,
    this.slideTransition = true,
    this.dynamicWidth,
    this.decoration,
    this.onHoverInside,
    required this.child,
  });

  final double maxWidth;
  final double maxHeight;
  final double? yOffset;
  final bool slideTransition;
  final bool? dynamicWidth;
  final OverlayDecoration? decoration;
  final void Function(bool value)? onHoverInside;
  final Widget child;

  @override
  State<_OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<_OverlayContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _animationController,
    );

    _animationController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: widget.decoration?._isUnStyled == true
            ? _contentWrapper(_unStyledContent)
            : _contentWrapper(_defaultContent),
      );

  Widget _contentWrapper(Widget content) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 18),
      child: SlideTransition(
        position: Tween(
          begin: Offset(0, widget.slideTransition ? -1 : 0),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOut)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _animation, curve: Curves.easeIn),
          child: content,
        ),
      ),
    );
  }

  Widget get _defaultContent => MouseRegion(
        onEnter: (_) => widget.onHoverInside?.call(true),
        onExit: (_) => widget.onHoverInside?.call(false),
        child: CardContainer(
          width: widget.decoration?.width,
          height: widget.decoration?.height,
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight <= 72 ? 72 : widget.maxHeight,
          ),
          margin: EdgeInsets.only(top: (widget.yOffset ?? 0)),
          padding: widget.decoration?.padding ?? EdgeInsets.zero,
          color: widget.decoration?.color ?? Colors.white,
          borderRadius: widget.decoration?.borderRadius ?? 8,
          border: widget.decoration?.border ??
              const Border.fromBorderSide(
                BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
              ),
          boxShadow: widget.decoration?.boxShadow ??
              const BoxShadow(
                offset: Offset(0, 3),
                blurRadius: 2,
                color: Colors.black12,
              ),
          clipBehavior: widget.decoration?.clipBehavior ?? Clip.none,
          child: widget.child,
        ),
      );

  Widget get _unStyledContent => MouseRegion(
        onEnter: (_) => widget.onHoverInside?.call(true),
        onExit: (_) => widget.onHoverInside?.call(false),
        child: Padding(
          padding: EdgeInsets.only(top: (widget.yOffset ?? 0)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth,
              maxHeight: widget.maxHeight <= 72 ? 72 : widget.maxHeight,
            ),
            child: widget.child,
          ),
        ),
      );
}

class OverlayDecoration {
  OverlayDecoration({
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.color,
    this.borderRadius = 8,
    this.border = const Border.fromBorderSide(
      BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
    ),
    this.boxShadow = const BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 2,
      color: Colors.black12,
    ),
    this.clipBehavior = Clip.none,
  }) : _isUnStyled = false;

  OverlayDecoration.unStyled() : _isUnStyled = true;

  final bool _isUnStyled;
  late final double? width;
  late final double? height;
  late final EdgeInsets padding;
  late final Color? color;
  late final double borderRadius;
  late final BoxBorder border;
  late final BoxShadow boxShadow;
  late final Clip clipBehavior;

  OverlayDecoration copyWith({
    double? width,
    double? height,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
    BoxBorder? border,
    BoxShadow? boxShadow,
    Clip? clipBehavior,
  }) {
    return OverlayDecoration(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      boxShadow: boxShadow ?? this.boxShadow,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }
}

enum OverlayAlign { left, center, right }

enum VerticalAxisSize { min, max }

class OverlayWrapper extends StatefulWidget {
  const OverlayWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<OverlayWrapper> createState() => _OverlayWrapperState();
}

class _OverlayWrapperState extends State<OverlayWrapper> {
  late final _entry = OverlayEntry(
    canSizeOverlay: true,
    opaque: true,
    builder: (BuildContext context) => widget.child,
  );

  @override
  void didUpdateWidget(OverlayWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  void dispose() {
    _entry
      ..remove()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);
}
