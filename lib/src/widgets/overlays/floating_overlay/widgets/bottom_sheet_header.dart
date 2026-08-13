part of '../floating_overlay.dart';

class const BottomSheetHeader({super.key, final HeaderTitle? title, final HeaderAction? action})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .centerRight,
      children: [
        title ?? const SizedBox(width: .infinity),
        if (action != null)
          Padding(padding: const .symmetric(vertical: 8, horizontal: 16), child: action!),
      ],
    );
  }
}
