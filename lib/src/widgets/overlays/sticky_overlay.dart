import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

enum OverlayAlign { left, center, right }

class StickyOverlay {
  StickyOverlay._();

  static final StickyOverlay _instance = StickyOverlay._();
  static StickyOverlay get instance => _instance;

  OverlayEntry? _overlayEntry;

  void create(
    BuildContext context, {
    required GlobalKey linkKey,
    required LayerLink link,
    bool dynamicWidth = false,
    bool slideTransition = true,
    bool closeOnTapOutside = true,
    bool closeOnTapLink = true,
    double? yOffset,
    OverlayAlign alignment = .center,
    OverlayDecoration decoration = const OverlayDecoration(
      padding: .symmetric(vertical: 8),
      color: Colors.white,
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: .5, color: Colors.black12)),
      elevation: 1,
      elevationType: .elevation,
      clipBehavior: .none,
    ),
    void Function(bool value)? onHoverInside,
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    remove();

    final linkContext = linkKey.currentContext;
    if (linkContext == null || !linkContext.mounted) {
      dev.log('Error: Key context tidak ditemukan atau unmounted.');
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => _OverlayLayer(
        link: link,
        linkContext: linkContext,
        dynamicWidth: dynamicWidth,
        slideTransition: slideTransition,
        closeOnTapOutside: closeOnTapOutside,
        closeOnTapLink: closeOnTapLink,
        yOffset: yOffset,
        alignment: alignment,
        decoration: decoration,
        onHoverInside: onHoverInside,
        onRemove: remove,
        contentBuilder: contentBuilder,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _OverlayLayer extends StatefulWidget {
  const _OverlayLayer({
    required this.link,
    required this.linkContext,
    required this.alignment,
    this.yOffset,
    required this.slideTransition,
    required this.dynamicWidth,
    required this.closeOnTapOutside,
    required this.closeOnTapLink,
    required this.decoration,
    this.onHoverInside,
    required this.onRemove,
    required this.contentBuilder,
  });

  final LayerLink link;
  final BuildContext linkContext;
  final OverlayAlign alignment;
  final double? yOffset;
  final bool slideTransition;
  final bool dynamicWidth;
  final bool closeOnTapOutside;
  final bool closeOnTapLink;
  final OverlayDecoration decoration;
  final void Function(bool value)? onHoverInside;
  final void Function() onRemove;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  State<_OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<_OverlayLayer> {
  final double _minTopOverlay = 80;

  ScrollNotificationObserverState? _scrollObserver;

  Size _linkSize = const Size(0, 0);
  Offset _linkPosition = const Offset(0, 0);
  Size _screenSize = const Size(0, 0);
  double _dynamicMaxHeight = 0;
  bool _isTopOverlay = false;
  double _alignmentYOffset = 0;
  double _alignmentXOffset = 0;
  Alignment _anchorAlignment = .topCenter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _set();

    _scrollObserver?.removeListener(_handleScrollNotification);

    _scrollObserver = ScrollNotificationObserver.maybeOf(widget.linkContext);
    _scrollObserver?.addListener(_handleScrollNotification);
  }

  @override
  void dispose() {
    _scrollObserver?.removeListener(_handleScrollNotification);

    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
      Debouncer.run(() => _set(isInitial: false), duration: const Duration(milliseconds: 150));
    }
  }

  void _set({bool isInitial = true}) {
    final renderBox = widget.linkContext.findRenderObject() as RenderBox;
    final linkSize = renderBox.size;
    final linkPosition = renderBox.localToGlobal(.zero);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final paddingBottom = mediaQuery.padding.bottom;
    final dynamicBottomMaxHeight =
        (size.height - (linkPosition.dy + linkSize.height + (widget.yOffset ?? 0))) -
        (14 + paddingBottom);
    final isTopOverlay = dynamicBottomMaxHeight < (_minTopOverlay - 10);

    final paddingTop = mediaQuery.padding.top;
    final dynamicTopMaxHeight = (linkPosition.dy - (widget.yOffset ?? 0)) - (14 + paddingTop);
    final dynamicMaxHeight = (isTopOverlay ? dynamicTopMaxHeight : dynamicBottomMaxHeight);

    _linkPosition = linkPosition;
    _linkSize = linkSize;
    _screenSize = size;
    _dynamicMaxHeight = dynamicMaxHeight;

    final alignmentYOffset = isTopOverlay ? -(linkSize.height - 18) : linkSize.height - 18;
    final double alignmentXOffset = switch (widget.alignment) {
      .left => -14,
      .center => 0,
      .right => 14,
    };
    final Alignment anchorAlignment = switch (widget.alignment) {
      .left => isTopOverlay ? .bottomLeft : .topLeft,
      .center => isTopOverlay ? .bottomCenter : .topCenter,
      .right => isTopOverlay ? .bottomRight : .topRight,
    };

    _alignmentXOffset = alignmentXOffset;
    _alignmentYOffset = alignmentYOffset;
    _anchorAlignment = anchorAlignment;

    _isTopOverlay = isTopOverlay;

    if (!isInitial && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.closeOnTapLink)
          Positioned(
            width: _linkSize.width,
            child: CompositedTransformFollower(
              link: widget.link,
              showWhenUnlinked: false,
              targetAnchor: .topCenter,
              followerAnchor: .topCenter,
              child: SizedBox(
                width: _linkSize.width,
                height: _linkSize.height,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        Positioned(
          width: widget.dynamicWidth ? null : (_linkSize.width + 28),
          child: CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            offset: Offset(_alignmentXOffset, _alignmentYOffset),
            targetAnchor: _anchorAlignment,
            followerAnchor: _anchorAlignment,
            child: Material(
              type: .transparency,
              child: _AnimationLayer(
                isTopOverlay: _isTopOverlay,
                slideTransition: widget.slideTransition,
                child: _OverlayContent(
                  isTopOverlay: _isTopOverlay,
                  maxWidth: _getMaxWidth(widget.alignment, _screenSize, _linkSize, _linkPosition),
                  maxHeight: widget.decoration.maxHeight ?? _dynamicMaxHeight,
                  yOffset: widget.yOffset,
                  closeOnTapOutside: widget.closeOnTapOutside,
                  decoration: widget.decoration,
                  onRemove: widget.onRemove,
                  onHoverInside: widget.onHoverInside,
                  child: widget.contentBuilder(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxWidth(OverlayAlign alignment, Size size, Size buttonSize, Offset position) {
    final leftRemainder = position.dx;
    final rightRemainder = size.width - (position.dx + buttonSize.width);
    final minSide = min(leftRemainder, rightRemainder);

    return switch (alignment) {
      .left => (rightRemainder + buttonSize.width) - 14,
      .center => (minSide * 2 + buttonSize.width) - 28,
      .right => (leftRemainder + buttonSize.width) - 14,
    };
  }
}

class _AnimationLayer extends StatefulWidget {
  const _AnimationLayer({
    required this.isTopOverlay,
    required this.slideTransition,
    required this.child,
  });

  final bool isTopOverlay;
  final bool slideTransition;
  final Widget child;

  @override
  State<_AnimationLayer> createState() => _AnimationLayerState();
}

class _AnimationLayerState extends State<_AnimationLayer> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    if (!widget.slideTransition) return;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController!.forward();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.slideTransition) {
      return Padding(
        padding: const .only(top: 18, left: 14, right: 14, bottom: 18),
        child: widget.child,
      );
    }

    return SizeTransition(
      sizeFactor: _animation!,
      axisAlignment: widget.isTopOverlay ? 1 : -1,
      child: Padding(
        padding: const .only(top: 18, left: 14, right: 14, bottom: 18),
        child: widget.child,
      ),
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    required this.isTopOverlay,
    required this.maxWidth,
    required this.maxHeight,
    this.yOffset,
    required this.closeOnTapOutside,
    required this.decoration,
    required this.onRemove,
    this.onHoverInside,
    required this.child,
  });

  final bool isTopOverlay;
  final double maxWidth;
  final double maxHeight;
  final double? yOffset;
  final bool closeOnTapOutside;
  final OverlayDecoration decoration;
  final void Function() onRemove;
  final void Function(bool value)? onHoverInside;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return decoration._isUnStyled == true ? _unStyledContent : _defaultContent;
  }

  Widget get _defaultContent => MouseRegion(
    onEnter: (_) => onHoverInside?.call(true),
    onExit: (_) => onHoverInside?.call(false),
    child: Padding(
      padding: isTopOverlay ? .only(bottom: (yOffset ?? 0)) : .only(top: (yOffset ?? 0)),
      child: TapRegion(
        onTapOutside: closeOnTapOutside ? (_) => onRemove() : null,
        child: Container(
          width: decoration.width,
          height: decoration.height,
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          padding: decoration.padding,
          decoration: BoxDecoration(
            color: decoration.color,
            borderRadius: .circular(decoration.borderRadius),
            border: decoration.border,
            boxShadow: DecorationUtils.elevation(
              decoration.elevation,
              elevationType: decoration.elevationType,
            ),
          ),
          clipBehavior: decoration.clipBehavior,
          child: child,
        ),
      ),
    ),
  );

  Widget get _unStyledContent => MouseRegion(
    onEnter: (_) => onHoverInside?.call(true),
    onExit: (_) => onHoverInside?.call(false),
    child: Padding(
      padding: isTopOverlay ? .only(bottom: (yOffset ?? 0)) : .only(top: (yOffset ?? 0)),
      child: TapRegion(
        onTapOutside: closeOnTapOutside ? (_) => onRemove() : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: child,
        ),
      ),
    ),
  );
}

class OverlayDecoration {
  const OverlayDecoration({
    this.width,
    this.height,
    this.maxHeight,
    this.padding = const .symmetric(vertical: 6),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: .5, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .elevation,
    this.clipBehavior = .none,
  }) : _isUnStyled = false;

  const OverlayDecoration.unStyled({this.maxHeight})
    : _isUnStyled = true,
      width = null,
      height = null,
      padding = .zero,
      color = Colors.white,
      borderRadius = 0,
      border = const .fromBorderSide(.none),
      elevation = 0,
      elevationType = .elevation,
      clipBehavior = .none;

  final bool _isUnStyled;
  final double? width;
  final double? height;
  final double? maxHeight;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final BoxBorder border;
  final double elevation;
  final ElevationType elevationType;
  final Clip clipBehavior;

  OverlayDecoration copyWith({
    double? width,
    double? height,
    double? maxHeight,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
    BoxBorder? border,
    double? elevation,
    ElevationType? elevationType,
    Clip? clipBehavior,
  }) {
    return OverlayDecoration(
      width: width ?? this.width,
      height: height ?? this.height,
      maxHeight: maxHeight ?? this.maxHeight,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      elevationType: elevationType ?? this.elevationType,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }
}

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
