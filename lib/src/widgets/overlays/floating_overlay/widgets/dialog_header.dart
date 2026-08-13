part of '../floating_overlay.dart';

class const DialogHeader({
  super.key,
  final IconData? icon,
  final double iconSize = 26,
  final Color? iconColor,
  final String? title,
  final double titleSize = 16,
  final FontWeight titleFontWeight = .w600,
  final HeaderAction? action,
}) extends StatelessWidget {
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
