import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

part 'models/layout_values.dart';
part 'models/overlay_decoration.dart';
part 'models/overlay_instance_option.dart';
part 'wrapper/sticky_overlay_wrapper.dart';

enum OverlayAlignment { left, center, right }

class StickyOverlay {
  StickyOverlay._();

  static final _instance = StickyOverlay._();
  static StickyOverlay get instance => _instance;

  static final _singleOverlayKey = GlobalKey();

  final Map<GlobalKey, ({OverlayEntry entry, void Function()? onDispose})> _overlays = {};

  void create(
    BuildContext context, {
    required GlobalKey targetKey,
    required LayerLink link,
    OverlayInstanceOption instanceOption = const .singleton(),
    bool removeOnTapOutside = true,
    bool removeOnTapTarget = true,
    OverlayDecoration decoration = const .dynamicWidth(
      offsetY: 6,
      offsetX: 8,
      marginY: 14,
      marginX: 14,
      alignment: .center,
      padding: .zero,
      color: Colors.white,
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
      useBarrier: false,
    ),
    void Function(bool value)? onHoverInside,
    required Widget Function(BuildContext context) contentBuilder,
    void Function()? onDispose,
  }) {
    final idKey = instanceOption is _MultipleInstance ? targetKey : _singleOverlayKey;

    _removeByKey(idKey);

    final targetContext = targetKey.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      dev.log('Error: Key context tidak ditemukan atau unmounted.');
      return;
    }

    final entry = OverlayEntry(
      builder: (_) => _OverlayLayer(
        link: link,
        targetContext: targetContext,
        removeOnTapOutside: removeOnTapOutside,
        removeOnTapTarget: removeOnTapTarget,
        decoration: decoration,
        onHoverInside: onHoverInside,
        onTapOutside: () => _removeByKey(idKey),
        contentBuilder: contentBuilder,
      ),
    );

    _overlays[idKey] = (entry: entry, onDispose: onDispose);

    Overlay.of(context).insert(entry);
  }

  void remove(OverlayInstanceOption option) {
    if (option is _MultipleInstance) {
      _removeByKey(option.targetKey);
    } else {
      _removeByKey(_singleOverlayKey);
    }
  }

  void clear() {
    final keys = _overlays.keys.toList();
    for (final key in keys) {
      _removeByKey(key);
    }
  }

  void _removeByKey(GlobalKey key) {
    if (_overlays.containsKey(key)) {
      final overlay = _overlays[key];
      overlay?.entry.remove();
      final onDisposeCallback = overlay?.onDispose;
      _overlays.remove(key);
      onDisposeCallback?.call();
    }
  }
}

class _OverlayLayer extends StatefulWidget {
  const _OverlayLayer({
    required this.link,
    required this.targetContext,
    required this.removeOnTapOutside,
    required this.removeOnTapTarget,
    required this.decoration,
    this.onHoverInside,
    required this.onTapOutside,
    required this.contentBuilder,
  });

  final LayerLink link;
  final BuildContext targetContext;
  final bool removeOnTapOutside;
  final bool removeOnTapTarget;
  final OverlayDecoration decoration;
  final void Function(bool value)? onHoverInside;
  final void Function() onTapOutside;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  State<_OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<_OverlayLayer> {
  bool _isInitial = true;
  bool _measuringContentWidth = true;

  final _changeDependeciesDebouncer = Debouncer(duration: const Duration(milliseconds: 150));
  final _scrollingDebouncer = Debouncer(duration: const Duration(milliseconds: 150));

  GlobalKey? _contentKey;
  Widget? _content;
  double? _staticSurfaceWidth;
  late OverlayDecoration _decoration;

  late final double _minTopOverlay;
  final double _elevationSurfaceY = 72;
  final double _elevationSurfaceX = 48;

  ScrollNotificationObserverState? _scrollObserver;

  Size _screenSize = const Size(0, 0);
  Size _targetSize = const Size(0, 0);
  Offset _targetPosition = const Offset(0, 0);
  double _maxHeight = 0;
  double _maxWidth = 0;
  bool _isTopOverlay = false;

  @override
  void initState() {
    super.initState();

    _content = widget.contentBuilder(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitial) {
      _contentKey = GlobalKey();
      _decoration = widget.decoration;
      _minTopOverlay = _decoration.flipOffset;
      _setInitialLayoutValues();
      _scrollObserver?.removeListener(_scrollNotification);
      _scrollObserver = null;
      if (_decoration._id == 2 || _decoration._id == 3) {
        _measuringContentWidth = false;
        if (_decoration._id == 2) _staticSurfaceWidth = _decoration._width;
        if (_decoration._id == 3) _staticSurfaceWidth = _targetSize.width;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _isInitial = false;
          await Future<void>.delayed(const Duration(milliseconds: 500));
          _initScrollObserver();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // await Future.delayed(const Duration(seconds: 1));
          _measuringContentWidth = false;
          if (mounted) _setStaticSurfaceWidth();
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _isInitial = false;
            await Future<void>.delayed(const Duration(milliseconds: 500));
            _initScrollObserver();
          });
        });
      }
    } else {
      _scrollObserver?.removeListener(_scrollNotification);
      _scrollObserver = null;
      _changeDependeciesDebouncer.run(() {
        _setInitialLayoutValues();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          _initScrollObserver();
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollObserver?.removeListener(_scrollNotification);
    _changeDependeciesDebouncer.dispose();
    _scrollingDebouncer.dispose();

    super.dispose();
  }

  void _scrollNotification(ScrollNotification notification) {
    _scrollingDebouncer.run(() {
      final renderBox = widget.targetContext.findRenderObject() as RenderBox;
      final targetPosition = renderBox.localToGlobal(.zero);
      if (targetPosition == _targetPosition) return;

      _scrollObserver?.removeListener(_scrollNotification);
      _scrollObserver = null;
      if (mounted) _setInitialLayoutValues();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        _initScrollObserver();
      });
    });
  }

  void _initScrollObserver() {
    _scrollObserver = widget.targetContext.mounted
        ? ScrollNotificationObserver.maybeOf(widget.targetContext)
        : null;
    _scrollObserver?.addListener(_scrollNotification);
  }

  void _setStaticSurfaceWidth() {
    setState(() => _staticSurfaceWidth = _contentKey?.currentContext?.size?.width);
  }

  void _setInitialLayoutValues() {
    final renderBox = widget.targetContext.findRenderObject() as RenderBox;
    _targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(.zero);
    _targetPosition = targetPosition;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    _screenSize = size;
    final paddingBottom = mediaQuery.padding.bottom;
    final bottomMaxHeight =
        (size.height - (targetPosition.dy + _targetSize.height + _decoration.offsetY)) -
        (_decoration.marginY + paddingBottom);
    _isTopOverlay = bottomMaxHeight < (_minTopOverlay - 10);
    final paddingTop = mediaQuery.padding.top;
    final topMaxHeight =
        (targetPosition.dy - _decoration.offsetY) - (_decoration.marginY + paddingTop);
    _maxHeight = _isTopOverlay ? topMaxHeight : bottomMaxHeight;

    if (!_isInitial && mounted) {
      setState(() {});
      return;
    }

    final decorationMaxWidth = widget.decoration._maxWidth;
    final maxWidth = _getMaxWidth;
    _maxWidth = min(maxWidth, decorationMaxWidth ?? maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    final layoutValues = _measuringContentWidth
        ? _getMeasuringLayoutValues
        : _decoration._id != 4
        ? _getLayoutValues
        : _getAdaptiveLayoutValues;

    return Stack(
      children: [
        if (_decoration.useBarrier)
          SizedBox(
            height: _screenSize.height,
            width: _screenSize.width,
            child: const ColoredBox(color: Colors.transparent),
          ),
        if (widget.removeOnTapTarget && !_decoration.useBarrier)
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
          left: _measuringContentWidth ? 0 : null,
          top: _measuringContentWidth ? 0 : null,
          width: _measuringContentWidth
              ? null
              : layoutValues.surfaceMaxWidth + (_elevationSurfaceX * 2),
          child: CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            offset: Offset(layoutValues.alignmentOffsetX, layoutValues.alignmentOffsetY),
            targetAnchor: layoutValues.anchorAlignment,
            followerAnchor: layoutValues.anchorAlignment,
            child: Opacity(
              opacity: _measuringContentWidth ? 0 : 1,
              // opacity: 1,
              child: Material(
                type: .transparency,
                // color: Colors.amber.withValues(alpha: .5),
                child: _AnimationLayer(
                  isTopOverlay: _isTopOverlay,
                  elevationSurfaceY: _elevationSurfaceY,
                  elevationSurfaceX: _elevationSurfaceX,
                  slideTransition: _measuringContentWidth
                      ? false
                      : _isInitial
                      ? _decoration.slideTransition
                      : false,
                  transitionOnInitial: widget.decoration._id == 2 || widget.decoration._id == 3,
                  child: SizedBox(
                    key: _contentKey,
                    child: _OverlayContent(
                      isTopOverlay: _isTopOverlay,
                      maxHeight: layoutValues.surfaceMaxHeight,
                      maxWidth: _measuringContentWidth ? _maxWidth : null,
                      offsetY: _decoration.offsetY,
                      removeOnTapOutside: widget.removeOnTapOutside,
                      decoration: _decoration,
                      onTapOutside: widget.onTapOutside,
                      onHoverInside: widget.onHoverInside,
                      child: _content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double get _getMaxWidth => _screenSize.width - _decoration.marginX;

  _LayoutValues get _getMeasuringLayoutValues {
    final decorationMaxHeight = _decoration.maxHeight?.clamp(
      _minTopOverlay,
      _screenSize.height - (_minTopOverlay + _decoration.marginY),
    );
    final finalDecorationMaxHeight = decorationMaxHeight ?? _maxHeight;
    final surfaceMaxHeight = min(_maxHeight, finalDecorationMaxHeight);

    return _LayoutValues(surfaceMaxHeight: surfaceMaxHeight);
  }

  _LayoutValues get _getLayoutValues {
    final decoration = widget.decoration;
    final screenWidth = _screenSize.width;
    final targetWidth = _targetSize.width;
    final targetPositionX = _targetPosition.dx;
    final alignment = decoration._alignment;
    final marginX = decoration.marginX;
    final offsetX = decoration._offsetX;
    double surfaceWidth = _staticSurfaceWidth != null ? _staticSurfaceWidth! : targetWidth;
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
    final maxLeft = max(.0, targetPositionX - marginX);
    final maxRight = max(.0, (screenWidth - marginX) - (targetPositionX + targetWidth));

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

    final dynamicWidth = targetWidth + leftOverhang + rightOverhang;
    final staticWidth = decoration._width ?? decoration._widthCopy;
    final fitToTargetWidth = targetWidth;

    if (dynamicWidth < (decoration._width ?? decoration._widthCopy)) {
      _decoration = decoration._convertTo(id: 1);
    } else {
      _decoration = decoration;
    }

    final surfaceMaxWidth = switch (_decoration._id) {
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

    final decorationMaxHeight = _decoration.maxHeight?.clamp(
      _minTopOverlay,
      _screenSize.height - (_minTopOverlay + _decoration.marginY),
    );
    final finalDecorationMaxHeight = decorationMaxHeight ?? _maxHeight;
    final surfaceMaxHeight = min(_maxHeight, finalDecorationMaxHeight);

    return _LayoutValues(
      surfaceMaxWidth: surfaceMaxWidth,
      surfaceMaxHeight: surfaceMaxHeight,
      alignmentOffsetY: alignmentOffsetY,
      alignmentOffsetX: alignmentOffsetX,
      anchorAlignment: anchorAlignment,
    );
  }

  _LayoutValues get _getAdaptiveLayoutValues {
    final screenWidth = _screenSize.width;
    final targetWidth = _targetSize.width;
    final marginX = _decoration.marginX;

    final maxContentWidth = screenWidth - marginX;

    double surfaceWidth = targetWidth;
    if (_staticSurfaceWidth != null) {
      surfaceWidth = _staticSurfaceWidth!;
    } else {
      surfaceWidth = maxContentWidth;
    }

    if (surfaceWidth > maxContentWidth) surfaceWidth = maxContentWidth;
    if (surfaceWidth < targetWidth) surfaceWidth = targetWidth;

    // print(_staticSurfaceWidth);
    // print(surfaceWidth);

    final leftOverhang = (surfaceWidth - targetWidth) / 2;
    final rightOverhang = surfaceWidth - targetWidth - leftOverhang;

    final surfaceLeftCoordinate = _targetPosition.dx - leftOverhang;
    final surfaceRightCoordinate = surfaceLeftCoordinate + surfaceWidth;

    double adaptiveShiftX = 0;
    if (surfaceRightCoordinate > screenWidth - marginX) {
      adaptiveShiftX = (screenWidth - marginX) - surfaceRightCoordinate;
    } else if (surfaceLeftCoordinate < marginX) {
      adaptiveShiftX = marginX - surfaceLeftCoordinate;
    }

    if (adaptiveShiftX > leftOverhang) adaptiveShiftX = leftOverhang;
    if (adaptiveShiftX < -rightOverhang) adaptiveShiftX = -rightOverhang;

    final surfaceMaxWidth = surfaceWidth;

    final alignmentOffsetY = _isTopOverlay
        ? -(_targetSize.height - _elevationSurfaceY)
        : _targetSize.height - _elevationSurfaceY;

    final alignmentOffsetX = adaptiveShiftX;

    final Alignment anchorAlignment = _isTopOverlay ? .bottomCenter : .topCenter;

    final decorationMaxHeight = _decoration.maxHeight?.clamp(
      _minTopOverlay,
      _screenSize.height - (_minTopOverlay + _decoration.marginY),
    );
    final finalDecorationMaxHeight = decorationMaxHeight ?? _maxHeight;
    final surfaceMaxHeight = min(_maxHeight, finalDecorationMaxHeight);

    return _LayoutValues(
      surfaceMaxWidth: surfaceMaxWidth,
      surfaceMaxHeight: surfaceMaxHeight,
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
    required this.transitionOnInitial,
    required this.child,
  });

  final bool isTopOverlay;
  final double elevationSurfaceY;
  final double elevationSurfaceX;
  final bool slideTransition;
  final bool transitionOnInitial;
  final Widget child;

  @override
  State<_AnimationLayer> createState() => _AnimationLayerState();
}

class _AnimationLayerState extends State<_AnimationLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);

    if (widget.slideTransition && widget.transitionOnInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _animationController.forward());
    } else {
      _animationController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _AnimationLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.slideTransition && !widget.transitionOnInitial) {
      _animationController.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _animationController.forward());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      alignment: widget.isTopOverlay ? .bottomCenter : .topCenter,
      child: Padding(
        padding: .only(
          top: widget.elevationSurfaceY,
          left: widget.elevationSurfaceX,
          right: widget.elevationSurfaceX,
          bottom: widget.elevationSurfaceY,
        ),
        child: widget.child,
      ),
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    required this.isTopOverlay,
    this.maxHeight,
    this.maxWidth,
    this.offsetY,
    required this.removeOnTapOutside,
    required this.decoration,
    required this.onTapOutside,
    this.onHoverInside,
    required this.child,
  });

  final bool isTopOverlay;
  final double? maxHeight;
  final double? maxWidth;
  final double? offsetY;
  final bool removeOnTapOutside;
  final OverlayDecoration decoration;
  final void Function() onTapOutside;
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
          onTapOutside: removeOnTapOutside ? (_) => onTapOutside() : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? .infinity,
              maxWidth: maxWidth ?? .infinity,
            ),
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
  _RenderDecoratedOverlay({required this._decoration}) {
    _updatePaddingCaches();
  }

  _OverlayDecoration _decoration;
  BoxPainter? _cachedPainter;

  late EdgeInsets _borderPadding;
  late EdgeInsets _totalPadding;
  late Offset _childOffset;

  set decoration(_OverlayDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    _cachedPainter?.dispose();
    _cachedPainter = null;

    _updatePaddingCaches();
    markNeedsLayout();
  }

  void _updatePaddingCaches() {
    _borderPadding = _decoration.border.dimensions.resolve(.ltr);
    _totalPadding = _borderPadding + _decoration.padding;
    _childOffset = Offset(_totalPadding.left, _totalPadding.top);
  }

  @override
  void dispose() {
    _cachedPainter?.dispose();

    super.dispose();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    final deflated = constraints.deflate(_totalPadding);

    double? constrainDimension(double? target, double min, double max) {
      if (target == null) return null;
      return (target - _totalPadding.horizontal).clamp(min, max);
    }

    final exactWidth = constrainDimension(_decoration.width, deflated.minWidth, deflated.maxWidth);
    final exactHeight = constrainDimension(
      _decoration.height,
      deflated.minHeight,
      deflated.maxHeight,
    );

    final childConstraints = deflated.copyWith(
      minWidth: exactWidth,
      maxWidth: exactWidth,
      minHeight: exactHeight,
      maxHeight: exactHeight,
    );

    child.layout(childConstraints, parentUsesSize: true);

    if (child.size.height == 0) {
      final emptySize = Size(child.size.width + _totalPadding.horizontal, 0.0);
      size = constraints.constrain(emptySize);
    } else {
      final totalSize = Size(
        _decoration.width ?? (child.size.width + _totalPadding.horizontal),
        _decoration.height ?? (child.size.height + _totalPadding.vertical),
      );
      size = constraints.constrain(totalSize);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (child.size.height == 0) {
      context.paintChild(child, offset);
      return;
    }

    _cachedPainter ??= BoxDecoration(
      color: _decoration.color,
      borderRadius: .circular(_decoration.borderRadius),
      border: _decoration.border,
      boxShadow: DecorationUtils.elevation(
        _decoration.elevation,
        elevationType: _decoration.elevationType,
      ),
    ).createBoxPainter(markNeedsPaint);

    _cachedPainter!.paint(context.canvas, offset, ImageConfiguration(size: size));

    final clipRect = _borderPadding.deflateRect(offset & size);

    final innerRadius = (_decoration.borderRadius - _borderPadding.left).clamp(.0, double.infinity);
    final innerRRect = RRect.fromRectAndRadius(clipRect, .circular(innerRadius));

    final childVisualOffset = offset + _childOffset;

    context.pushClipRRect(needsCompositing, .zero, clipRect, innerRRect, (innerContext, _) {
      innerContext.paintChild(child, childVisualOffset);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;

    if (child.size.height == 0) return child.hitTest(result, position: position);

    return result.addWithPaintOffset(
      offset: _childOffset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (child.size.height > 0) {
      transform.translateByDouble(_childOffset.dx, _childOffset.dy, .0, 1);
    }
    super.applyPaintTransform(child, transform);
  }
}
