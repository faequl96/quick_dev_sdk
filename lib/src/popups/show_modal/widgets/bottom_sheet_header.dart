part of '../show_modal.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({super.key, this.useHandleBar, this.handleColor, this.action});

  final bool? useHandleBar;
  final Color? handleColor;
  final HeaderAction? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (useHandleBar == true)
          SizedBox(
            height: 16 + 4 + (action?.iconSize ?? 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(height: 16 + 4 + (action?.iconSize ?? 12), width: double.maxFinite),
        if (action != null) Positioned(top: 8, right: 14, child: action!),
      ],
    );
  }
}
