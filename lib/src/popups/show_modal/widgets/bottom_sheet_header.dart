part of '../show_modal.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({super.key, this.title, this.action});

  final HeaderTitle? title;
  final HeaderAction? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .centerRight,
      children: [
        title ?? const SizedBox(width: .maxFinite),
        if (action != null) Padding(padding: const .symmetric(vertical: 8, horizontal: 16), child: action!),
      ],
    );
  }
}
