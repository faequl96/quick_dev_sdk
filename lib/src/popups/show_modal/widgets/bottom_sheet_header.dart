part of '../show_modal.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({
    super.key,
    this.useHandleBar,
    this.action,
  });

  final bool? useHandleBar;
  final HeaderAction? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (useHandleBar == true)
          SizedBox(
            height: 16 + 4 + (action?.iconSize ?? 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        if (action != null) Positioned(top: 8, right: 14, child: action!),
      ],
    );
  }
}
