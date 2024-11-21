part of '../show_modal.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    super.key,
    this.titleIcon,
    this.titleIconSize = 26,
    this.title,
    this.titleSize = 16,
    this.titleFontWeight = FontWeight.bold,
    this.action,
  });

  final IconData? titleIcon;
  final double titleIconSize;
  final String? title;
  final double titleSize;
  final FontWeight titleFontWeight;
  final HeaderAction? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (title != null || titleIcon != null)
          SizedBox(
            height: 16 + 4 + (action?.iconSize ?? 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                if (titleIcon != null) ...[
                  Icon(titleIcon, size: titleIconSize),
                  const SizedBox(width: 6),
                ],
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: titleFontWeight,
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
