import 'dart:developer';

import 'package:quick_dev_sdk/src/widgets/basic/card_container.dart';
import 'package:flutter/material.dart';

class ShowOverlay {
  ShowOverlay._();

  static final ShowOverlay _instance = ShowOverlay._();
  static ShowOverlay get instance => _instance;

  OverlayEntry? _overlayEntry;

  late BuildContext _context;

  Alignment _getAlignment(OverlayAlign alignment) {
    final alignMap = {
      OverlayAlign.left: Alignment.topLeft,
      OverlayAlign.center: Alignment.topCenter,
      OverlayAlign.right: Alignment.topRight,
    };
    return alignMap[alignment]!;
  }

  double _getAlignOffset(OverlayAlign alignment) {
    final Map<OverlayAlign, double> alignMap = {
      OverlayAlign.left: -14,
      OverlayAlign.center: 0,
      OverlayAlign.right: 14,
    };
    return alignMap[alignment]!;
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
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    _removePreviousOverlay();

    if (key.currentContext != null) _context = key.currentContext!;
    if (_context.mounted == false) {
      log('Your key is not associated with any widget "ShowOverlay.of(GlobalKey key)"');
      return;
    }

    final renderBox = _context.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;

    Alignment align = _getAlignment(alignment);

    _overlayEntry = OverlayEntry(builder: (_) {
      return Stack(
        children: [
          Positioned(
            width: dynamicWidth ? null : (buttonSize.width + 28),
            child: CompositedTransformFollower(
              link: linkToTarget,
              showWhenUnlinked: false,
              offset: Offset(
                _getAlignOffset(alignment),
                buttonSize.height + ((yOffset ?? 0) - 10),
              ),
              targetAnchor: align,
              followerAnchor: align,
              child: Material(
                type: MaterialType.transparency,
                child: TapRegion(
                  onTapOutside: closeOnTapOutside ? (_) => remove() : null,
                  child: _OverlayContent(
                    slideTransition: slideTransition,
                    dynamicWidth: dynamicWidth,
                    decoration: decoration,
                    child: contentBuilder(_context),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
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
    this.slideTransition = true,
    this.dynamicWidth,
    this.decoration,
    required this.child,
  });

  final bool slideTransition;
  final bool? dynamicWidth;
  final OverlayDecoration? decoration;
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

    if (widget.slideTransition) _animationController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, left: 14, right: 14, bottom: 18),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animation,
              curve: Curves.easeIn,
            ),
            child: CardContainer(
              width: widget.decoration?.width,
              height: widget.decoration?.height,
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
              child: IntrinsicWidth(
                child: IntrinsicHeight(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
  });

  final double? width;
  final double? height;
  final EdgeInsets padding;
  final Color? color;
  final double borderRadius;
  final BoxBorder border;
  final BoxShadow boxShadow;
  final Clip clipBehavior;
}

enum OverlayAlign { left, center, right }
