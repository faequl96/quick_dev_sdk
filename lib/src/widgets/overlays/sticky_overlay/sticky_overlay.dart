import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

part 'models/overlay_decoration.dart';
part 'wrapper/sticky_overlay_wrapper.dart';

enum OverlayAlignment { left, center, right }

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
    required Widget Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder,
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
  final Widget Function(BuildContext context, {bool? isMeasuringWidth}) contentBuilder;

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
      if (widget.decoration._id != 3) _contentKey = GlobalKey();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (widget.decoration._id != 3) {
          // await Future.delayed(const Duration(seconds: 1));
          if (mounted) _setStaticOverlaySurfaceWidth();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          _scrollObserver?.removeListener(_scrollNotification);
          _initScrollObserver();
          _isInitial = false;
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          _scrollObserver?.removeListener(_scrollNotification);
          _initScrollObserver();
        }
      });
    } else {
      Debouncer.run(() {
        _staticOverlaySurfaceWidth = null;
        _set(isInitial: false);
        _scrollObserver?.removeListener(_scrollNotification);
        _scrollObserver = null;
        if (widget.decoration._id != 3) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (mounted) _setStaticOverlaySurfaceWidth();
            await Future<void>.delayed(const Duration(milliseconds: 100));
            _initScrollObserver();
          });
        }
      }, duration: const Duration(milliseconds: 150));
    }
  }

  @override
  void dispose() {
    _scrollObserver?.removeListener(_scrollNotification);

    super.dispose();
  }

  void _scrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
      Debouncer.run(() {
        if (mounted) _set(isInitial: false);
      }, duration: const Duration(milliseconds: 150));
    }
  }

  void _initScrollObserver() {
    _scrollObserver = widget.targetContext.mounted
        ? ScrollNotificationObserver.maybeOf(widget.targetContext)
        : null;
    _scrollObserver?.addListener(_scrollNotification);
  }

  void _setStaticOverlaySurfaceWidth() {
    setState(() => _staticOverlaySurfaceWidth = _contentKey?.currentContext?.size?.width);
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
    _maxWidth = _getMaxWidth;

    if (_maxWidth < widget.decoration._width) {
      _decoration = _decoration._convertTo(id: 1);
    } else {
      _decoration = widget.decoration;
    }

    if (!isInitial && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if ((_decoration._id == 1 || _decoration._id == 4) && _staticOverlaySurfaceWidth == null) {
      final border = _decoration.border;
      final padding = _decoration.padding;
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Opacity(
              opacity: 0,
              child: Material(
                type: MaterialType.transparency,
                child: SizedBox(
                  key: _contentKey,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _decoration._id == 4
                          ? _maxWidth
                          : _maxWidth + (_elevationSurfaceX * 2),
                      maxHeight: 100,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
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
          ),
        ],
      );
    }

    final layoutValues = _decoration._id != 4 ? _getLayoutValues : _getAdaptiveLayoutValues;

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
          width: layoutValues.width,
          child: CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            offset: Offset(layoutValues.alignmentOffsetX, layoutValues.alignmentOffsetY),
            targetAnchor: layoutValues.anchorAlignment,
            followerAnchor: layoutValues.anchorAlignment,
            child: Material(
              // type: .transparency,
              color: Colors.amber.withValues(alpha: .5),
              child: _AnimationLayer(
                isTopOverlay: _isTopOverlay,
                elevationSurfaceY: _elevationSurfaceY,
                elevationSurfaceX: _elevationSurfaceX,
                slideTransition: _isInitial ? _decoration.slideTransition : false,
                child: _OverlayContent(
                  isTopOverlay: _isTopOverlay,
                  maxWidth: _decoration._id == 4
                      ? _maxWidth
                      : (_maxWidth < _targetSize.width ? _targetSize.width : _maxWidth),
                  maxHeight: (_decoration.maxHeight ?? 0) < _maxHeight
                      ? _decoration.maxHeight ?? _maxHeight
                      : _maxHeight,
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

  double get _getMaxWidth {
    if (_decoration._id == 4) {
      return _screenWidth - _decoration.marginX + (_elevationSurfaceX * 2);
    }

    final leftRemainder = _targetPositionX;
    final rightRemainder = _screenWidth - (_targetPositionX + _targetSize.width);
    final minSide = min(leftRemainder, rightRemainder);

    return switch (_decoration._alignment) {
      .left => ((rightRemainder + _targetSize.width) - _decoration.marginX) + _decoration._offsetX,
      .center => (minSide * 2 + _targetSize.width) - (_decoration.marginX * 2),
      .right => ((leftRemainder + _targetSize.width) - _decoration.marginX) + _decoration._offsetX,
    };
  }

  ({double width, double alignmentOffsetY, double alignmentOffsetX, Alignment anchorAlignment})
  get _getLayoutValues {
    final targetWidth = _targetSize.width;
    final alignment = _decoration._alignment;
    final marginX = _decoration.marginX;
    final offsetX = _decoration._offsetX;

    double surfaceWidth = _staticOverlaySurfaceWidth != null
        ? _staticOverlaySurfaceWidth! - (_elevationSurfaceX * 2)
        : targetWidth;
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
    final staticWidth = _decoration._width + (_elevationSurfaceX * 2);
    final fitToTargetWidth = targetWidth + (_elevationSurfaceX * 2);
    final width = switch (_decoration._id) {
      1 => dynamicWidth,
      2 => staticWidth,
      3 => fitToTargetWidth,
      int() => dynamicWidth,
    };

    final alignmentOffsetY = _isTopOverlay
        ? -(_targetSize.height - _elevationSurfaceY)
        : _targetSize.height - _elevationSurfaceY;

    final alignmentOffsetX = switch (_decoration._alignment) {
      .left => -(_elevationSurfaceX + (_decoration._id == 1 ? leftOverhang : _decoration._offsetX)),
      .center => .0,
      .right => _elevationSurfaceX + (_decoration._id == 1 ? rightOverhang : _decoration._offsetX),
    };

    final Alignment anchorAlignment = switch (_decoration._alignment) {
      .left => _isTopOverlay ? .bottomLeft : .topLeft,
      .center => _isTopOverlay ? .bottomCenter : .topCenter,
      .right => _isTopOverlay ? .bottomRight : .topRight,
    };

    return (
      width: width,
      alignmentOffsetY: alignmentOffsetY,
      alignmentOffsetX: alignmentOffsetX,
      anchorAlignment: anchorAlignment,
    );
  }

  ({double width, double alignmentOffsetY, double alignmentOffsetX, Alignment anchorAlignment})
  get _getAdaptiveLayoutValues {
    final targetWidth = _targetSize.width;
    final marginX = _decoration.marginX;

    final maxContentWidth = _screenWidth - marginX;

    double surfaceWidth = targetWidth;
    if (_staticOverlaySurfaceWidth != null) {
      surfaceWidth = _staticOverlaySurfaceWidth! - (_elevationSurfaceX * 2);
    } else {
      surfaceWidth = maxContentWidth;
    }

    if (surfaceWidth > maxContentWidth) surfaceWidth = maxContentWidth;
    if (surfaceWidth < targetWidth) surfaceWidth = targetWidth;

    final leftOverhang = (surfaceWidth - targetWidth) / 2;
    final surfaceLeftCoordinate = _targetPositionX - leftOverhang;
    final surfaceRightCoordinate = surfaceLeftCoordinate + surfaceWidth;

    double adaptiveShiftX = 0;
    if (surfaceRightCoordinate > _screenWidth - marginX) {
      adaptiveShiftX = _screenWidth - surfaceRightCoordinate;
    } else if (surfaceLeftCoordinate < marginX) {
      adaptiveShiftX = marginX - surfaceLeftCoordinate;
    }
    if (adaptiveShiftX > leftOverhang) adaptiveShiftX = leftOverhang;

    final width = surfaceWidth + (_elevationSurfaceX * 2);

    final alignmentOffsetY = _isTopOverlay
        ? -(_targetSize.height - _elevationSurfaceY)
        : _targetSize.height - _elevationSurfaceY;

    final alignmentOffsetX = adaptiveShiftX;

    final Alignment anchorAlignment = _isTopOverlay ? .bottomCenter : .topCenter;

    return (
      width: width,
      alignmentOffsetY: alignmentOffsetY,
      alignmentOffsetX: alignmentOffsetX,
      anchorAlignment: anchorAlignment,
    );
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

    if (!widget.slideTransition) return Padding(padding: padding, child: widget.child);

    return SizeTransition(
      sizeFactor: _animation!,
      alignment: widget.isTopOverlay ? .bottomCenter : .topCenter,
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
                width: decoration._id == 2 ? decoration._width : null,
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
