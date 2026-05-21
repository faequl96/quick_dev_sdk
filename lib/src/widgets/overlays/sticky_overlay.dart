import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

enum OverlayAlign { left, center, right }

class OverlayDecoration {
  const OverlayDecoration({
    this.height,
    this.maxHeight,
    this.width,
    this.yOffset = 6,
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
  }) : _fitToTargetWidth = false;

  const OverlayDecoration.fitToTargetWidth({
    this.height,
    this.maxHeight,
    this.yOffset = 6,
    this.marginY = 14,
    this.marginX = 14,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
  }) : _fitToTargetWidth = true,
       width = null,
       alignment = .center;

  final double? height;
  final double? maxHeight;
  final double? width;
  final bool _fitToTargetWidth;
  final double yOffset;
  final OverlayAlign alignment;
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
    double? yOffset,
    double? marginY,
    double? marginX,
    OverlayAlign? alignment,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
    Border? border,
    double? elevation,
    ElevationType? elevationType,
    bool? slideTransition,
  }) {
    if (_fitToTargetWidth) {
      return .fitToTargetWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        yOffset: yOffset ?? this.yOffset,
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

    return OverlayDecoration(
      height: height ?? this.height,
      maxHeight: maxHeight ?? this.maxHeight,
      width: width ?? this.width,
      yOffset: yOffset ?? this.yOffset,
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
    OverlayDecoration decoration = const .fitToTargetWidth(
      yOffset: 6,
      marginY: 14,
      marginX: 14,
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
  GlobalKey? _contentKey;
  double? _staticOverlaySurfaceWidth;
  OverlayDecoration _decoration = const OverlayDecoration();
  bool get _useDynamicWidth => !_decoration._fitToTargetWidth && _decoration.width == null;

  final double _minTopOverlay = 80;
  final double _elevationSurfaceY = 72;
  final double _elevationSurfaceX = 48;

  ScrollNotificationObserverState? _scrollObserver;

  Size _targetSize = const Size(0, 0);
  double _maxHeight = 0;
  double _maxWidth = 0;
  bool _isTopOverlay = false;
  double _alignmentYOffset = 0;
  double _alignmentXOffset = 0;
  Alignment _anchorAlignment = .topCenter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _decoration = widget.decoration;

    _set();

    if (_useDynamicWidth) {
      _contentKey = GlobalKey();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _staticOverlaySurfaceWidth = _contentKey?.currentContext?.size?.width);
        }
      });
    }

    _scrollObserver?.removeListener(_handleScrollNotification);

    _scrollObserver = ScrollNotificationObserver.maybeOf(widget.targetContext);
    _scrollObserver?.addListener(_handleScrollNotification);
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
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final paddingBottom = mediaQuery.padding.bottom;
    final bottomMaxHeight =
        (size.height - (targetPosition.dy + _targetSize.height + _decoration.yOffset)) -
        (_decoration.marginY + paddingBottom);
    _isTopOverlay = bottomMaxHeight < (_minTopOverlay - 10);
    final paddingTop = mediaQuery.padding.top;
    final topMaxHeight =
        (targetPosition.dy - _decoration.yOffset) - (_decoration.marginY + paddingTop);

    _maxHeight = (_isTopOverlay ? topMaxHeight : bottomMaxHeight);
    _maxWidth = _getMaxWidth(_decoration.alignment, size, _targetSize, targetPosition);

    _alignmentYOffset = _isTopOverlay
        ? -(_targetSize.height - _elevationSurfaceY)
        : _targetSize.height - _elevationSurfaceY;
    _alignmentXOffset = switch (_decoration.alignment) {
      .left => -_elevationSurfaceX,
      .center => 0,
      .right => _elevationSurfaceX,
    };
    _anchorAlignment = switch (_decoration.alignment) {
      .left => _isTopOverlay ? .bottomLeft : .topLeft,
      .center => _isTopOverlay ? .bottomCenter : .topCenter,
      .right => _isTopOverlay ? .bottomRight : .topRight,
    };

    if (!isInitial && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_useDynamicWidth && _staticOverlaySurfaceWidth == null) {
      final border = _decoration.border;
      final padding = _decoration.padding;
      return Stack(
        children: [
          Opacity(
            opacity: 1,
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
        ],
      );
    }

    final surfaceWidth = _maxWidth < _targetSize.width
        ? (_targetSize.width + (_elevationSurfaceX * 2))
        : (_staticOverlaySurfaceWidth ?? 0);
    final dynamicWidth = _decoration.width != null
        ? (_decoration.width! + (_elevationSurfaceX * 2))
        : surfaceWidth;
    final width = !_decoration._fitToTargetWidth
        ? dynamicWidth
        : _targetSize.width + (_elevationSurfaceX * 2);

    // print('_maxWidth: $_maxWidth');
    // print('_targetSize.width: ${_targetSize.width}');
    // print('_staticOverlaySurfaceWidth: $_staticOverlaySurfaceWidth');
    // print('surfaceWidth: $surfaceWidth');
    // print('dynamicWidth: $dynamicWidth');
    // print('width: $width');

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
            offset: Offset(_alignmentXOffset, _alignmentYOffset),
            targetAnchor: _anchorAlignment,
            followerAnchor: _anchorAlignment,
            child: Material(
              type: .transparency,
              child: _AnimationLayer(
                isTopOverlay: _isTopOverlay,
                elevationSurfaceY: _elevationSurfaceY,
                elevationSurfaceX: _elevationSurfaceX,
                slideTransition: _decoration.slideTransition,
                child: _OverlayContent(
                  isTopOverlay: _isTopOverlay,
                  maxWidth: _maxWidth < _targetSize.width ? _targetSize.width : _maxWidth,
                  maxHeight: _decoration.maxHeight ?? _maxHeight,
                  yOffset: _decoration.yOffset,
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

  double _getMaxWidth(OverlayAlign alignment, Size size, Size buttonSize, Offset position) {
    final leftRemainder = position.dx;
    final rightRemainder = size.width - (position.dx + buttonSize.width);
    final minSide = min(leftRemainder, rightRemainder);

    return switch (alignment) {
      .left => (rightRemainder + buttonSize.width) - _decoration.marginX,
      .center => (minSide * 2 + buttonSize.width) - (_decoration.marginX * 2),
      .right => (leftRemainder + buttonSize.width) - _decoration.marginX,
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
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverInside?.call(true),
      onExit: (_) => onHoverInside?.call(false),
      child: Padding(
        padding: isTopOverlay ? .only(bottom: (yOffset ?? 0)) : .only(top: (yOffset ?? 0)),
        child: TapRegion(
          onTapOutside: closeOnTapOutside ? (_) => onRemove() : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: _DecoratedOverlay(
              decoration: _OverlayDecoration(
                height: decoration.height,
                width: decoration.width,
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
