import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:quick_dev_sdk/src/popups/show_modal/widgets/modal_dialog_content.dart';
import 'package:flutter/material.dart';

part 'models.dart';
part 'widgets/bottom_sheet_header.dart';
part 'widgets/dialog_header.dart';
part 'widgets/header_action.dart';

class ShowModal {
  static void bottomSheet(
    BuildContext context, {
    bool dismissible = true,
    Color barrierColor = Colors.black26,
    BottomSheetDecoration? decoration,
    BottomSheetHeader? header,
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    showModalBottomSheet<void>(
      backgroundColor: decoration?.color ?? Colors.white,
      barrierColor: barrierColor,
      shape: RoundedRectangleBorder(
        side: decoration?.borderSide ?? BorderSide.none,
        borderRadius: decoration?.borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
      ),
      isDismissible: dismissible,
      isScrollControlled: true,
      constraints: const BoxConstraints(),
      clipBehavior: decoration?.clipBehavior ?? Clip.hardEdge,
      context: context,
      builder: (context) {
        return SizedBox(
          height: decoration?.height,
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) header,
              contentBuilder(context),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
            ],
          ),
        );
      },
    );
  }

  static void dialog(
    BuildContext context, {
    bool dismissible = true,
    Color barrierColor = Colors.black26,
    bool slideTransition = true,
    DialogDecoration? decoration,
    DialogHeader? header,
    required Widget Function(BuildContext context) contentBuilder,
  }) {
    final dialogContent = Dialog(
      clipBehavior: decoration?.clipBehavior ?? Clip.hardEdge,
      backgroundColor: decoration?.color ?? Colors.white,
      shadowColor: decoration?.shadowColor ?? Colors.black12,
      elevation: decoration?.elevation ?? 24,
      shape: RoundedRectangleBorder(
        side: decoration?.borderSide ?? BorderSide.none,
        borderRadius: decoration?.borderRadius ?? BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        width: decoration?.width,
        height: decoration?.height,
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: ModalDialogContent(
              header: header,
              child: contentBuilder(context),
            ),
          ),
        ),
      ),
    );

    if (slideTransition == true) {
      showGeneralDialog<void>(
        context: context,
        barrierLabel: "showAnimatedDialog",
        barrierDismissible: dismissible,
        barrierColor: barrierColor,
        pageBuilder: (_, __, ___) => dialogContent,
        transitionBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: child,
          );
        },
      );
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: dismissible,
        barrierColor: barrierColor,
        builder: (context) => dialogContent,
      );
    }
  }
}