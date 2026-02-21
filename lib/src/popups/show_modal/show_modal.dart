import 'dart:async';

import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:quick_dev_sdk/src/popups/show_modal/widgets/bottom_sheet_dialog_content.dart';
import 'package:quick_dev_sdk/src/popups/show_modal/widgets/modal_dialog_content.dart';
import 'package:flutter/material.dart';

part 'models.dart';
part 'widgets/bottom_sheet_header.dart';
part 'widgets/dialog_header.dart';
part 'widgets/header_action.dart';
part 'widgets/header_title.dart';

class ShowModal {
  ShowModal._();

  static Future<T> bottomSheet<T>(
    BuildContext context, {
    bool dismissible = true,
    bool canPop = true,
    bool enableDrag = true,
    Color barrierColor = Colors.black26,
    BottomSheetDecoration? decoration,
    List<Wallpaper>? wallpapers,
    BottomSheetHeader? header,
    required Widget Function(BuildContext context) contentBuilder,
  }) async {
    final completer = Completer<T>();

    showModalBottomSheet<T>(
      context: context,
      backgroundColor: decoration?.color ?? Colors.white,
      barrierColor: barrierColor,
      shape: RoundedRectangleBorder(
        side: decoration?.borderSide ?? .none,
        borderRadius: decoration?.borderRadius ?? const .only(topLeft: .circular(10), topRight: .circular(10)),
      ),
      isDismissible: dismissible,
      isScrollControlled: true,
      enableDrag: enableDrag,
      constraints: decoration?.constraints,
      clipBehavior: decoration?.clipBehavior ?? .hardEdge,
      builder: (_) => PopScope(
        canPop: canPop,
        child: BottomSheetDialogContent(
          decoration: decoration,
          wallpapers: wallpapers,
          header: header,
          contentBuilder: contentBuilder,
        ),
      ),
    ).then((value) => completer.complete(value));

    return await completer.future;
  }

  static Future<T> dialog<T>(
    BuildContext context, {
    bool dismissible = true,
    Color barrierColor = Colors.black26,
    bool slideTransition = true,
    DialogDecoration? decoration,
    List<Wallpaper>? wallpapers,
    DialogHeader? header,
    required Widget Function(BuildContext context) contentBuilder,
  }) async {
    final completer = Completer<T>();

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
          if (wallpapers != null) ...wallpapers,
          ModalDialogContent(
            width: decoration?.width,
            height: decoration?.height,
            padding: decoration?.padding ?? .zero,
            header: header,
            child: contentBuilder(context),
          ),
        ],
      ),
    );

    if (slideTransition == true) {
      showGeneralDialog<T>(
        context: context,
        barrierLabel: 'showAnimatedDialog',
        barrierDismissible: dismissible,
        barrierColor: barrierColor,
        pageBuilder: (_, _, _) => dialogContent,
        transitionBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
            child: child,
          );
        },
      ).then((value) => completer.complete(value));
    } else {
      showDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        barrierColor: barrierColor,
        builder: (_) => dialogContent,
      ).then((value) => completer.complete(value));
    }

    return await completer.future;
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
