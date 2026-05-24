import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

enum OverlayAlignment { left, center, right }

class OverlayDecoration {
  const OverlayDecoration.dynamicWidth({
    this.height,
    this.maxHeight,
    this.offsetY = 6,
    this.offsetX = 8,
    this.marginY = 14,
    this.marginX = 14,
    this.alignment = .center,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
  }) : _id = 1,
       width = 280;

  const OverlayDecoration.staticWidth({
    this.height,
    this.maxHeight,
    this.width = 280,
    this.offsetY = 6,
    this.offsetX = 8,
    this.marginY = 14,
    this.marginX = 14,
    this.alignment = .center,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
  }) : _id = 2;

  const OverlayDecoration.fitToTargetWidth({
    this.height,
    this.maxHeight,
    this.offsetY = 6,
    this.marginY = 14,
    this.marginX = 14,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
  }) : _id = 3,
       width = 280,
       offsetX = 0,
       alignment = .center;

  final int _id;
  final double? height;
  final double? maxHeight;
  final double width;
  final double offsetY;
  final double offsetX;
  final OverlayAlignment alignment;
  final double marginY;
  final double marginX;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final Border border;
  final double elevation;
  final ElevationType elevationType;
  final bool slideTransition;

  OverlayDecoration copyWith({
    double? height,
    double? maxHeight,
    double? width,
    double? offsetY,
    double? offsetX,
    double? marginY,
    double? marginX,
    OverlayAlignment? alignment,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
    Border? border,
    double? elevation,
    ElevationType? elevationType,
    bool? slideTransition,
  }) {
    if (_id == 3) {
      return .fitToTargetWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        offsetY: offsetY ?? this.offsetY,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
      );
    }

    if (_id == 2) {
      return .staticWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        width: width ?? this.width,
        offsetY: offsetY ?? this.offsetY,
        offsetX: offsetX ?? this.offsetX,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        alignment: alignment ?? this.alignment,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
      );
    }

    return .dynamicWidth(
      height: height ?? this.height,
      maxHeight: maxHeight ?? this.maxHeight,
      offsetY: offsetY ?? this.offsetY,
      marginY: marginY ?? this.marginY,
      marginX: marginX ?? this.marginX,
      alignment: alignment ?? this.alignment,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      elevationType: elevationType ?? this.elevationType,
      slideTransition: slideTransition ?? this.slideTransition,
    );
  }
}

class StickyOverlay {
  StickyOverlay._();

  static final StickyOverlay _instance = StickyOverlay._();
  static StickyOverlay get instance => _instance;

  OverlayEntry? _overlayEntry;

  void create(
    BuildContext context, {
    required GlobalKey targetKey,
    required LayerLink link,
    bool closeOnTapOutside = true,
    bool closeOnTapTarget = true,
    OverlayDecoration decoration = const .dynamicWidth(
      offsetY: 6,
      offsetX: 8,
      marginY: 14,
      marginX: 14,
      alignment: .center,
      padding: .symmetric(vertical: 8),
      color: Colors.white,
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
    ),
    void Function(bool value)? onHoverInside,
    required Widget? Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder,
  }) {
    remove();

    final targetContext = targetKey.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      dev.log('Error: Key context tidak ditemukan atau unmounted.');
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => _OverlayLayer(
        link: link,
        targetContext: targetContext,
        closeOnTapOutside: closeOnTapOutside,
        closeOnTapTarget: closeOnTapTarget,
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
    required this.targetContext,
    required this.closeOnTapOutside,
    required this.closeOnTapTarget,
    required this.decoration,
    this.onHoverInside,
    required this.onRemove,
    required this.contentBuilder,
  });

  final LayerLink link;
  final BuildContext targetContext;
  final bool closeOnTapOutside;
  final bool closeOnTapTarget;
  final OverlayDecoration decoration;
  final void Function(bool value)? onHoverInside;
  final void Function() onRemove;
  final Widget? Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder;

  @override
  State<_OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<_OverlayLayer> {
  bool _isInitial = true;

  GlobalKey? _contentKey;
  double? _staticOverlaySurfaceWidth;
  late OverlayDecoration _decoration;

  final double _minTopOverlay = 80;
  final double _elevationSurfaceY = 72;
  final double _elevationSurfaceX = 48;

  ScrollNotificationObserverState? _scrollObserver;

  double _screenWidth = 0;
  Size _targetSize = const Size(0, 0);
  double _targetPositionX = 0;
  double _maxHeight = 0;
  double _maxWidth = 0;
  bool _isTopOverlay = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitial) {
      _decoration = widget.decoration;
      _set();
      if (_decoration._id == 1) _contentKey = GlobalKey();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_decoration._id != 1) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          _scrollObserver?.removeListener(_handleScrollNotification);
          _scrollObserver = widget.targetContext.mounted
              ? ScrollNotificationObserver.maybeOf(widget.targetContext)
              : null;
          _scrollObserver?.addListener(_handleScrollNotification);
        } else {
          // await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            setState(() => _staticOverlaySurfaceWidth = _contentKey?.currentContext?.size?.width);
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
          _scrollObserver?.removeListener(_handleScrollNotification);
          _scrollObserver = widget.targetContext.mounted
              ? ScrollNotificationObserver.maybeOf(widget.targetContext)
              : null;
          _scrollObserver?.addListener(_handleScrollNotification);
          _isInitial = false;
        }
      });
    } else {
      Debouncer.run(() {
        _staticOverlaySurfaceWidth = null;
        _set(isInitial: false);
        _scrollObserver?.removeListener(_handleScrollNotification);
        _scrollObserver = null;
        if (_decoration._id == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (mounted) {
              setState(() => _staticOverlaySurfaceWidth = _contentKey?.currentContext?.size?.width);
            }
            await Future<void>.delayed(const Duration(milliseconds: 100));
            _scrollObserver = widget.targetContext.mounted
                ? ScrollNotificationObserver.maybeOf(widget.targetContext)
                : null;
            _scrollObserver?.addListener(_handleScrollNotification);
          });
        }
      }, duration: const Duration(milliseconds: 150));
    }
  }

  @override
  void dispose() {
    _scrollObserver?.removeListener(_handleScrollNotification);

    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
      Debouncer.run(() {
        if (mounted) _set(isInitial: false);
      }, duration: const Duration(milliseconds: 150));
    }
  }

  void _set({bool isInitial = true}) {
    final renderBox = widget.targetContext.findRenderObject() as RenderBox;
    _targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(.zero);
    _targetPositionX = targetPosition.dx;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    _screenWidth = size.width;
    final paddingBottom = mediaQuery.padding.bottom;
    final bottomMaxHeight =
        (size.height - (targetPosition.dy + _targetSize.height + _decoration.offsetY)) -
        (_decoration.marginY + paddingBottom);
    _isTopOverlay = bottomMaxHeight < (_minTopOverlay - 10);
    final paddingTop = mediaQuery.padding.top;
    final topMaxHeight =
        (targetPosition.dy - _decoration.offsetY) - (_decoration.marginY + paddingTop);

    _maxHeight = _isTopOverlay ? topMaxHeight : bottomMaxHeight;
    _maxWidth = _getMaxWidth(_decoration.alignment, size, _targetSize, targetPosition);

    if (!isInitial && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_decoration._id == 1 && _staticOverlaySurfaceWidth == null) {
      final border = _decoration.border;
      final padding = _decoration.padding;
      return Stack(
        children: [
          Opacity(
            opacity: 0,
            child: Material(
              type: .transparency,
              // color: Colors.amber,
              child: SizedBox(
                key: _contentKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _maxWidth + (_elevationSurfaceX * 2),
                    maxHeight: 100,
                  ),
                  child: Padding(
                    padding: .only(
                      top: _elevationSurfaceY + border.top.width + padding.top,
                      left: _elevationSurfaceX + border.left.width + padding.left,
                      right: _elevationSurfaceX + border.right.width + padding.right,
                      bottom: _elevationSurfaceY + border.bottom.width + padding.bottom,
                    ),
                    child: widget.contentBuilder(widget.targetContext, isMeasuringWidth: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final targetWidth = _targetSize.width;
    final alignment = _decoration.alignment;
    final marginX = _decoration.marginX;
    final offsetX = _decoration.offsetX;

    double surfaceWidth = _staticOverlaySurfaceWidth ?? targetWidth;
    if (surfaceWidth < targetWidth) surfaceWidth = targetWidth;
    double leftOverhang = 0;
    double rightOverhang = 0;

    final isSymmetric = alignment == .center || surfaceWidth <= targetWidth + (offsetX * 2);

    if (isSymmetric) {
      leftOverhang = rightOverhang = (surfaceWidth - targetWidth) / 2;
    } else if (alignment == .left) {
      leftOverhang = offsetX;
      rightOverhang = surfaceWidth - targetWidth - offsetX;
    } else {
      leftOverhang = surfaceWidth - targetWidth - offsetX;
      rightOverhang = offsetX;
    }

    // Batasi Overhang Jika Menabrak Margin Layar
    final maxLeft = max(.0, _targetPositionX - marginX);
    final maxRight = max(.0, (_screenWidth - marginX) - (_targetPositionX + targetWidth));

    leftOverhang = min(leftOverhang, maxLeft);
    rightOverhang = min(rightOverhang, maxRight);

    if (isSymmetric) {
      // Ambil overhang yang paling kecil (paling tercekik margin) lalu samakan keduanya.
      final minOverhang = min(leftOverhang, rightOverhang);
      leftOverhang = minOverhang;
      rightOverhang = minOverhang;
    } else if (alignment == .right && leftOverhang < rightOverhang) {
      rightOverhang = leftOverhang;
    } else if (alignment == .left && rightOverhang < leftOverhang) {
      leftOverhang = rightOverhang;
    }

    final dynamicWidth = targetWidth + leftOverhang + rightOverhang + (_elevationSurfaceX * 2);
    final staticWidth = _decoration.width + (_elevationSurfaceX * 2);
    final fitToTargetWidth = targetWidth + (_elevationSurfaceX * 2);
    final width = switch (_decoration._id) {
      1 => dynamicWidth,
      2 => staticWidth,
      3 => fitToTargetWidth,
      int() => dynamicWidth,
    };

    final alignmentoffsetY = _isTopOverlay
        ? -(_targetSize.height - _elevationSurfaceY)
        : _targetSize.height - _elevationSurfaceY;

    final alignmentoffsetX = switch (alignment) {
      .left => -(_elevationSurfaceX + leftOverhang),
      .center => .0,
      .right => _elevationSurfaceX + rightOverhang,
    };

    final Alignment anchorAlignment = switch (alignment) {
      .left => _isTopOverlay ? .bottomLeft : .topLeft,
      .center => _isTopOverlay ? .bottomCenter : .topCenter,
      .right => _isTopOverlay ? .bottomRight : .topRight,
    };

    return Stack(
      children: [
        if (widget.closeOnTapTarget)
          Positioned(
            width: _targetSize.width,
            child: CompositedTransformFollower(
              link: widget.link,
              showWhenUnlinked: false,
              targetAnchor: .topCenter,
              followerAnchor: .topCenter,
              child: SizedBox(
                width: _targetSize.width,
                height: _targetSize.height,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        Positioned(
          width: width,
          child: CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            offset: Offset(alignmentoffsetX, alignmentoffsetY),
            targetAnchor: anchorAlignment,
            followerAnchor: anchorAlignment,
            child: Material(
              type: .transparency,
              // color: Colors.amber,
              child: _AnimationLayer(
                isTopOverlay: _isTopOverlay,
                elevationSurfaceY: _elevationSurfaceY,
                elevationSurfaceX: _elevationSurfaceX,
                slideTransition: _isInitial ? _decoration.slideTransition : false,
                child: _OverlayContent(
                  isTopOverlay: _isTopOverlay,
                  maxWidth: _maxWidth < _targetSize.width ? _targetSize.width : _maxWidth,
                  maxHeight: _decoration.maxHeight ?? _maxHeight,
                  offsetY: _decoration.offsetY,
                  closeOnTapOutside: widget.closeOnTapOutside,
                  decoration: _decoration,
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

  double _getMaxWidth(
    OverlayAlignment alignment,
    Size size,
    Size targetSize,
    Offset targetPosition,
  ) {
    final leftRemainder = targetPosition.dx;
    final rightRemainder = size.width - (targetPosition.dx + targetSize.width);
    final minSide = min(leftRemainder, rightRemainder);

    return switch (alignment) {
      .left => ((rightRemainder + targetSize.width) - _decoration.marginX) + _decoration.offsetX,
      .center => (minSide * 2 + targetSize.width) - (_decoration.marginX * 2),
      .right => ((leftRemainder + targetSize.width) - _decoration.marginX) + _decoration.offsetX,
    };
  }
}

class _AnimationLayer extends StatefulWidget {
  const _AnimationLayer({
    required this.isTopOverlay,
    required this.elevationSurfaceY,
    required this.elevationSurfaceX,
    required this.slideTransition,
    required this.child,
  });

  final bool isTopOverlay;
  final double elevationSurfaceY;
  final double elevationSurfaceX;
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
      duration: const Duration(milliseconds: 400),
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
    final padding = EdgeInsets.only(
      top: widget.elevationSurfaceY,
      left: widget.elevationSurfaceX,
      right: widget.elevationSurfaceX,
      bottom: widget.elevationSurfaceY,
    );

    if (!widget.slideTransition) {
      return Padding(padding: padding, child: widget.child);
    }

    return SizeTransition(
      sizeFactor: _animation!,
      axisAlignment: widget.isTopOverlay ? 1 : -1,
      // alignment: widget.isTopOverlay ? .topCenter : .bottomCenter,
      child: Padding(padding: padding, child: widget.child),
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    required this.isTopOverlay,
    required this.maxWidth,
    required this.maxHeight,
    this.offsetY,
    required this.closeOnTapOutside,
    required this.decoration,
    required this.onRemove,
    this.onHoverInside,
    required this.child,
  });

  final bool isTopOverlay;
  final double maxWidth;
  final double maxHeight;
  final double? offsetY;
  final bool closeOnTapOutside;
  final OverlayDecoration decoration;
  final void Function() onRemove;
  final void Function(bool value)? onHoverInside;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverInside?.call(true),
      onExit: (_) => onHoverInside?.call(false),
      child: Padding(
        padding: isTopOverlay ? .only(bottom: (offsetY ?? 0)) : .only(top: (offsetY ?? 0)),
        child: TapRegion(
          onTapOutside: closeOnTapOutside ? (_) => onRemove() : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: _DecoratedOverlay(
              decoration: _OverlayDecoration(
                height: decoration.height,
                width: decoration._id == 2 ? decoration.width : null,
                padding: decoration.padding,
                color: decoration.color,
                borderRadius: decoration.borderRadius,
                border: decoration.border,
                elevation: decoration.elevation,
                elevationType: decoration.elevationType,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayDecoration {
  const _OverlayDecoration({
    this.height,
    this.width,
    required this.padding,
    required this.color,
    required this.borderRadius,
    required this.border,
    required this.elevation,
    required this.elevationType,
  });

  final double? height;
  final double? width;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final BoxBorder border;
  final double elevation;
  final ElevationType elevationType;
}

class _DecoratedOverlay extends SingleChildRenderObjectWidget {
  const _DecoratedOverlay({required this.decoration, required super.child});

  final _OverlayDecoration decoration;

  @override
  _RenderDecoratedOverlay createRenderObject(BuildContext context) {
    return _RenderDecoratedOverlay(decoration: decoration);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderDecoratedOverlay renderObject) {
    renderObject.decoration = decoration;
  }
}

class _RenderDecoratedOverlay extends RenderProxyBox {
  _RenderDecoratedOverlay({required this._decoration});

  _OverlayDecoration _decoration;
  BoxPainter? _cachedPainter;

  set decoration(_OverlayDecoration value) {
    if (_decoration != value) {
      _decoration = value;
      _cachedPainter?.dispose();
      _cachedPainter = null;
      markNeedsLayout();
    }
  }

  @override
  void dispose() {
    _cachedPainter?.dispose();

    super.dispose();
  }

  @override
  void performLayout() {
    if (child != null) {
      final borderPadding = _decoration.border.dimensions.resolve(.ltr);

      final totalInternalPadding = borderPadding + _decoration.padding;

      final deflatedConstraints = BoxConstraints(
        minWidth: (constraints.minWidth - totalInternalPadding.horizontal).clamp(.0, .infinity),
        maxWidth: (constraints.maxWidth - totalInternalPadding.horizontal).clamp(.0, .infinity),
        minHeight: (constraints.minHeight - totalInternalPadding.vertical).clamp(.0, .infinity),
        maxHeight: (constraints.maxHeight - totalInternalPadding.vertical).clamp(.0, .infinity),
      );

      final childConstraints = deflatedConstraints.copyWith(
        minWidth: _decoration.width != null
            ? (_decoration.width! - totalInternalPadding.horizontal).clamp(
                deflatedConstraints.minWidth,
                deflatedConstraints.maxWidth,
              )
            : null,
        maxWidth: _decoration.width != null
            ? (_decoration.width! - totalInternalPadding.horizontal).clamp(
                deflatedConstraints.minWidth,
                deflatedConstraints.maxWidth,
              )
            : null,
        minHeight: _decoration.height != null
            ? (_decoration.height! - totalInternalPadding.vertical).clamp(
                deflatedConstraints.minHeight,
                deflatedConstraints.maxHeight,
              )
            : null,
        maxHeight: _decoration.height != null
            ? (_decoration.height! - totalInternalPadding.vertical).clamp(
                deflatedConstraints.minHeight,
                deflatedConstraints.maxHeight,
              )
            : null,
      );

      child!.layout(childConstraints, parentUsesSize: true);

      if (child!.size.height == 0) {
        size = child!.size;
      } else {
        final totalSize = Size(
          _decoration.width ?? (child!.size.width + totalInternalPadding.horizontal),
          _decoration.height ?? (child!.size.height + totalInternalPadding.vertical),
        );
        size = constraints.constrain(totalSize);
      }
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.size.height > 0) {
      final BoxDecoration texturizedDecoration = BoxDecoration(
        color: _decoration.color,
        borderRadius: .circular(_decoration.borderRadius),
        border: _decoration.border,
        boxShadow: DecorationUtils.elevation(
          _decoration.elevation,
          elevationType: _decoration.elevationType,
        ),
      );

      _cachedPainter ??= texturizedDecoration.createBoxPainter(markNeedsPaint);
      _cachedPainter!.paint(context.canvas, offset, ImageConfiguration(size: size));

      final borderPadding = _decoration.border.dimensions.resolve(.ltr);

      final clipX = offset.dx + borderPadding.left;
      final clipY = offset.dy + borderPadding.top;
      final clipWidth = size.width - borderPadding.horizontal;
      final clipHeight = size.height - borderPadding.vertical;
      final clipRect = Rect.fromLTWH(clipX, clipY, clipWidth, clipHeight);

      final outerRadius = _decoration.borderRadius;
      final double innerRadiusX = (outerRadius - borderPadding.left).clamp(.0, .infinity);
      final double innerRadiusY = (outerRadius - borderPadding.top).clamp(.0, .infinity);
      final innerRRect = RRect.fromRectAndRadius(clipRect, .elliptical(innerRadiusX, innerRadiusY));

      final totalInternalPadding = borderPadding + _decoration.padding;
      final childX = offset.dx + totalInternalPadding.left;
      final childY = offset.dy + totalInternalPadding.top;

      context.pushClipRRect(needsCompositing, .zero, clipRect, innerRRect, (
        PaintingContext innerContext,
        Offset innerOffset,
      ) {
        innerContext.paintChild(child!, Offset(childX, childY));
      });
    } else if (child != null) {
      context.paintChild(child!, offset);
    }
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
