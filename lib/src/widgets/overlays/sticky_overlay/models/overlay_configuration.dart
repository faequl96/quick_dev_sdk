part of '../sticky_overlay.dart';

class OverlayConfiguration {
  const OverlayConfiguration.dynamicWidth({
    this.height,
    this.maxHeight,
    this._maxWidth,
    this.offsetY = 6,
    this._offsetX = 8,
    this.marginY = 14,
    this.marginX = 14,
    this._alignment = .center,
    this.flipOffset = 80,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
    this.useBarrier = false,
  }) : _id = 1,
       _width = null,
       _widthCopy = 0;

  const OverlayConfiguration.staticWidth({
    this.height,
    this.maxHeight,
    required double width,
    this.offsetY = 6,
    this._offsetX = 8,
    this.marginY = 14,
    this.marginX = 14,
    this._alignment = .center,
    this.flipOffset = 80,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
    this.useBarrier = false,
  }) : _id = 2,
       _width = width > 40 ? width : 40,
       _widthCopy = width > 40 ? width : 40,
       _maxWidth = null;

  const OverlayConfiguration.fitToTargetWidth({
    this.height,
    this.maxHeight,
    this.offsetY = 6,
    this.marginY = 14,
    this.marginX = 14,
    this.flipOffset = 80,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
    this.useBarrier = false,
  }) : _id = 3,
       _width = null,
       _widthCopy = 0,
       _maxWidth = null,
       _offsetX = 0,
       _alignment = .center;

  const OverlayConfiguration.adaptive({
    this._maxWidth,
    this.offsetY = 6,
    this.marginY = 14,
    this.marginX = 14,
    this.flipOffset = 80,
    this.padding = const .symmetric(vertical: 8),
    this.color = Colors.white,
    this.borderRadius = 8,
    this.border = const .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
    this.elevation = 1,
    this.elevationType = .shadow,
    this.slideTransition = true,
    this.useBarrier = false,
  }) : _id = 4,
       height = null,
       maxHeight = null,
       _width = null,
       _widthCopy = 0,
       _offsetX = 0,
       _alignment = .center;

  final int _id;
  final double? height;
  final double? maxHeight;
  final double? _width;
  final double _widthCopy;
  final double? _maxWidth;
  final double offsetY;
  final double _offsetX;
  final double marginY;
  final double marginX;
  final OverlayAlignment _alignment;
  final double flipOffset;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final Border border;
  final double elevation;
  final ElevationType elevationType;
  final bool slideTransition;
  final bool useBarrier;

  OverlayConfiguration copyWith({
    double? height,
    double? maxHeight,
    double? width,
    double? maxWidth,
    double? offsetY,
    double? offsetX,
    double? marginY,
    double? marginX,
    OverlayAlignment? alignment,
    double? flipOffset,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
    Border? border,
    double? elevation,
    ElevationType? elevationType,
    bool? slideTransition,
    bool? useBarrier,
  }) {
    if (_id == 4) {
      return .adaptive(
        maxWidth: maxWidth ?? _maxWidth,
        offsetY: offsetY ?? this.offsetY,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        flipOffset: flipOffset ?? this.flipOffset,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
        useBarrier: useBarrier ?? this.useBarrier,
      );
    }

    if (_id == 3) {
      return .fitToTargetWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        offsetY: offsetY ?? this.offsetY,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        flipOffset: flipOffset ?? this.flipOffset,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
        useBarrier: useBarrier ?? this.useBarrier,
      );
    }

    if (_id == 2) {
      return .staticWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        width: width ?? _widthCopy,
        offsetY: offsetY ?? this.offsetY,
        offsetX: offsetX ?? _offsetX,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        alignment: alignment ?? _alignment,
        flipOffset: flipOffset ?? this.flipOffset,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
        useBarrier: useBarrier ?? this.useBarrier,
      );
    }

    return .dynamicWidth(
      height: height ?? this.height,
      maxHeight: maxHeight ?? this.maxHeight,
      maxWidth: maxWidth ?? _maxWidth,
      offsetY: offsetY ?? this.offsetY,
      offsetX: offsetX ?? _offsetX,
      marginY: marginY ?? this.marginY,
      marginX: marginX ?? this.marginX,
      alignment: alignment ?? _alignment,
      flipOffset: flipOffset ?? this.flipOffset,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      elevationType: elevationType ?? this.elevationType,
      slideTransition: slideTransition ?? this.slideTransition,
      useBarrier: useBarrier ?? this.useBarrier,
    );
  }

  OverlayConfiguration _convertTo({
    required int id,
    double? height,
    double? maxHeight,
    double? maxWidth,
    double? width,
    double? offsetY,
    double? offsetX,
    double? marginY,
    double? marginX,
    OverlayAlignment? alignment,
    double? flipOffset,
    EdgeInsets? padding,
    Color? color,
    double? borderRadius,
    Border? border,
    double? elevation,
    ElevationType? elevationType,
    bool? slideTransition,
    bool? useBarrier,
  }) {
    if (_id == 4) {
      return .adaptive(
        maxWidth: maxWidth ?? _maxWidth,
        offsetY: offsetY ?? this.offsetY,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        flipOffset: flipOffset ?? this.flipOffset,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
        useBarrier: useBarrier ?? this.useBarrier,
      );
    }

    if (id == 3) {
      return .fitToTargetWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        offsetY: offsetY ?? this.offsetY,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        flipOffset: flipOffset ?? this.flipOffset,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
        useBarrier: useBarrier ?? this.useBarrier,
      );
    }

    if (id == 2) {
      return .staticWidth(
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        width: width ?? _widthCopy,
        offsetY: offsetY ?? this.offsetY,
        offsetX: offsetX ?? _offsetX,
        marginY: marginY ?? this.marginY,
        marginX: marginX ?? this.marginX,
        alignment: alignment ?? _alignment,
        flipOffset: flipOffset ?? this.flipOffset,
        padding: padding ?? this.padding,
        color: color ?? this.color,
        borderRadius: borderRadius ?? this.borderRadius,
        border: border ?? this.border,
        elevation: elevation ?? this.elevation,
        elevationType: elevationType ?? this.elevationType,
        slideTransition: slideTransition ?? this.slideTransition,
        useBarrier: useBarrier ?? this.useBarrier,
      );
    }

    return .dynamicWidth(
      height: height ?? this.height,
      maxHeight: maxHeight ?? this.maxHeight,
      maxWidth: maxWidth ?? _maxWidth,
      offsetY: offsetY ?? this.offsetY,
      offsetX: offsetX ?? _offsetX,
      marginY: marginY ?? this.marginY,
      marginX: marginX ?? this.marginX,
      alignment: alignment ?? _alignment,
      flipOffset: flipOffset ?? this.flipOffset,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      elevationType: elevationType ?? this.elevationType,
      slideTransition: slideTransition ?? this.slideTransition,
      useBarrier: useBarrier ?? this.useBarrier,
    );
  }
}
