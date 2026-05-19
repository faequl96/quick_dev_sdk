import 'dart:async';

import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

part 'models/bottom_sheet_decoration.dart';
part 'models/dialog_decoration.dart';
part 'models/position.dart';
part 'models/wallpaper.dart';

part 'widgets/bottom_sheet_content.dart';
part 'widgets/bottom_sheet_header.dart';
part 'widgets/dialog_content.dart';
part 'widgets/dialog_header.dart';
part 'widgets/header_action.dart';
part 'widgets/header_title.dart';

class FloatingOverlay {
  FloatingOverlay._();

  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    bool dismissible = true,
    Color barrierColor = Colors.black26,
    bool useSafeArea = true,
    bool canPop = true,
    bool enableDrag = true,
    BottomSheetDecoration? decoration,
    BottomSheetHeader? header,
    List<Wallpaper>? wallpapers,
    required Widget Function(BuildContext context) contentBuilder,
  }) async {
    final borderRadius = const BorderRadius.only(topLeft: .circular(10), topRight: .circular(10));

    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: decoration?.color ?? Colors.white,
      barrierColor: barrierColor,
      shape: RoundedRectangleBorder(
        side: decoration?.borderSide ?? .none,
        borderRadius: decoration?.borderRadius ?? borderRadius,
      ),
      isDismissible: dismissible,
      useSafeArea: useSafeArea,
      isScrollControlled: true,
      enableDrag: enableDrag,
      constraints: decoration?.constraints,
      clipBehavior: decoration?.clipBehavior ?? .hardEdge,
      builder: (_) => PopScope(
        canPop: canPop,
        child: BottomSheetContent(
          decoration: decoration,
          wallpapers: wallpapers,
          header: header,
          contentBuilder: contentBuilder,
        ),
      ),
    );
  }

  static Future<T?> showDialog<T>(
    BuildContext context, {
    bool dismissible = true,
    Color barrierColor = Colors.black26,
    bool slideTransition = true,
    DialogDecoration? decoration,
    DialogHeader? header,
    List<Wallpaper>? wallpapers,
    required Widget Function(BuildContext context) contentBuilder,
  }) async {
    final dialogContent = Dialog(
      clipBehavior: decoration?.clipBehavior ?? .hardEdge,
      backgroundColor: decoration?.color ?? Colors.white,
      shadowColor: decoration?.shadowColor ?? Colors.black12,
      elevation: decoration?.elevation ?? 24,
      shape: RoundedRectangleBorder(
        side: decoration?.borderSide ?? .none,
        borderRadius: decoration?.borderRadius ?? .circular(10.0),
      ),
      child: Stack(
        children: [
          ...?wallpapers,
          DialogContent(
            width: decoration?.width,
            height: decoration?.height,
            padding: decoration?.padding ?? .zero,
            header: header,
            child: contentBuilder(context),
          ),
        ],
      ),
    );

    return await showGeneralDialog<T>(
      context: context,
      barrierLabel: !slideTransition ? 'showDialog' : 'showAnimatedDialog',
      barrierDismissible: dismissible,
      barrierColor: barrierColor,
      pageBuilder: (_, _, _) => dialogContent,
      transitionBuilder: (_, animation, _, child) {
        if (!slideTransition) return child;
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
          child: child,
        );
      },
    );
  }

  static Future<T?> showAdaptive<T>(
    BuildContext context, {
    bool dismissible = true,
    Color barrierColor = Colors.black26,

    bool sheetUseSafeArea = true,
    bool sheetCanPop = true,
    bool sheetEnableDrag = true,
    BottomSheetDecoration? sheetDecoration,
    BottomSheetHeader? sheetHeader,

    bool dialogSlideTransition = true,
    DialogDecoration? dialogDecoration,
    DialogHeader? dialogHeader,

    List<Wallpaper>? wallpapers,
    required Widget Function(BuildContext context) contentBuilder,
  }) async {
    final isMobile = !(MediaQuery.of(context).size.width >= 980);

    if (isMobile) {
      return await showBottomSheet<T>(
        context,
        dismissible: dismissible,
        barrierColor: barrierColor,
        useSafeArea: sheetUseSafeArea,
        canPop: sheetCanPop,
        enableDrag: sheetEnableDrag,
        decoration: sheetDecoration,
        header: sheetHeader,
        wallpapers: wallpapers,
        contentBuilder: contentBuilder,
      );
    } else {
      return await showDialog<T>(
        context,
        dismissible: dismissible,
        barrierColor: barrierColor,
        slideTransition: dialogSlideTransition,
        decoration: dialogDecoration,
        header: dialogHeader,
        wallpapers: wallpapers,
        contentBuilder: contentBuilder,
      );
    }
  }

  static List<Wallpaper> builtInWallpapers({bool? isError}) {
    return [
      Wallpaper(
        height: 300,
        width: 300,
        position: const Position(top: -140, left: -184),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: .circular(150),
            color: isError == true ? Colors.red.shade50 : Colors.blue.shade50,
          ),
        ),
      ),
      Wallpaper(
        height: 110,
        width: 110,
        position: const Position(top: -36, right: -28),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: .circular(55), color: Colors.amber.shade100),
        ),
      ),
    ];
  }
}
