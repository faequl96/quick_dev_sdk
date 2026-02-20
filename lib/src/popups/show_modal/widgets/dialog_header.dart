part of '../show_modal.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    super.key,
    this.icon,
    this.iconSize = 26,
    this.iconColor,
    this.title,
    this.titleSize = 16,
    this.titleFontWeight = .bold,
    this.action,
  });

  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final String? title;
  final double titleSize;
  final FontWeight titleFontWeight;
  final HeaderAction? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (title != null || icon != null)
          SizedBox(
            height: 16 + 4 + (action?.iconSize ?? 24),
            child: Row(
              crossAxisAlignment: .center,
              mainAxisAlignment: .start,
              children: [
                const SizedBox(width: 16),
                if (icon != null) ...[Icon(icon, size: iconSize), const SizedBox(width: 6)],
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(fontSize: titleSize, fontWeight: titleFontWeight),
                  ),
              ],
            ),
          )
        else
          SizedBox(height: 16 + 4 + (action?.iconSize ?? 24)),
        if (action != null) Positioned(top: 8, right: 14, child: action!),
      ],
    );
  }
}
