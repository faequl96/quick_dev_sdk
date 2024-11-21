import 'dart:developer';

import 'package:quick_dev_sdk/src/widgets/card_container.dart';
import 'package:flutter/material.dart';

class ShowOverlay {
  ShowOverlay._();

  static final ShowOverlay _instance = ShowOverlay._();
  static ShowOverlay get instance => _instance;

  OverlayEntry? _overlayEntry;

  late BuildContext _context;

  void create({
    required GlobalKey key,
    required LayerLink linkToTarget,
    bool dynamicWidth = false,
    bool slideTransition = true,
    bool closeOnTapOutside = true,
    Offset? offset,
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

    _overlayEntry = OverlayEntry(builder: (_) {
      return Stack(
        children: [
          Positioned(
            width: dynamicWidth ? null : (buttonSize.width + 28),
            child: CompositedTransformFollower(
              link: linkToTarget,
              showWhenUnlinked: false,
              offset: Offset(
                offset?.dx ?? 0,
                buttonSize.height + ((offset?.dy ?? 0) - 10),
              ),
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.topCenter,
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
              border: widget.decoration?.border,
              boxShadow: widget.decoration?.boxShadow ??
                  const BoxShadow(
                    offset: Offset(0, 2.5),
                    blurRadius: 2,
                    color: Colors.black12,
                    spreadRadius: 0.5,
                  ),
              clipBehavior: widget.decoration?.clipBehavior ?? Clip.none,
              child:
                  IntrinsicWidth(child: IntrinsicHeight(child: widget.child)),
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
    this.border,
    this.boxShadow = const BoxShadow(
      offset: Offset(0, 2.5),
      blurRadius: 2,
      color: Colors.black12,
      spreadRadius: 0.5,
    ),
    this.clipBehavior = Clip.none,
  });

  final double? width;
  final double? height;
  final EdgeInsets padding;
  final Color? color;
  final double borderRadius;
  final BoxBorder? border;
  final BoxShadow boxShadow;
  final Clip clipBehavior;
}
