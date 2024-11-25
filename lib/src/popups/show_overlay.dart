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

  double _getMaxWidth({
    required OverlayAlign alignment,
    required Size size,
    required Size buttonSize,
    required Offset position,
  }) {
    double leftRemainder = size.width - position.dx;
    double rightRemainder = size.width - (position.dx + buttonSize.width);
    List<double> remainders = [leftRemainder, rightRemainder];
    double minNumber = remainders[0];
    for (var number in remainders) {
      minNumber = min(minNumber, number);
    }
    final Map<OverlayAlign, double> alignMap = {
      OverlayAlign.left: size.width - (position.dx + buttonSize.width),
      OverlayAlign.center: minNumber,
      OverlayAlign.right: size.width - position.dx,
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
        size.height - (position.dy + buttonSize.height + (yOffset ?? 0));

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
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
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
    required this.maxWidth,
    required this.maxHeight,
    this.slideTransition = true,
    this.dynamicWidth,
    this.decoration,
    required this.child,
  });

  final double maxWidth;
  final double maxHeight;
  final bool slideTransition;
  final bool? dynamicWidth;
  final OverlayDecoration? decoration;
  final Widget child;

  @override
  State<_OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<_OverlayContent>
    with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  double? _staticHeight;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.decoration?.height == null) {
        setState(() => _staticHeight = _key.currentContext?.size?.height);
      }
      if (widget.slideTransition) _animationController.forward();
    });

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
            opacity: CurvedAnimation(parent: _animation, curve: Curves.easeIn),
            child: CardContainer(
              key: _key,
              width: widget.decoration?.width,
              height: _staticHeight ?? widget.decoration?.height,
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxHeight <= 72 ? 72 : widget.maxHeight,
              ),
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
