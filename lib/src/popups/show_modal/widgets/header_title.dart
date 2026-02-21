part of '../show_modal.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({
    super.key,
    required this.icon,
    this.iconSize = 28,
    this.iconColor,
    required this.title,
    this.titleSize,
    this.titleColor,
  }) : isHandleBar = false,
       color = null;

  const HeaderTitle.handleBar({super.key, this.color})
    : isHandleBar = true,
      icon = Icons.check,
      iconSize = 28,
      iconColor = null,
      title = '',
      titleSize = null,
      titleColor = null;

  final bool isHandleBar;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final String title;
  final double? titleSize;
  final Color? titleColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isHandleBar) {
      return SizedBox(
        height: 20,
        width: .maxFinite,
        child: Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              width: 60,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color ?? Colors.grey.shade600, borderRadius: .circular(4)),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: .maxFinite,
      child: Row(
        crossAxisAlignment: .center,
        mainAxisAlignment: .start,
        children: [
          const SizedBox(width: 20),
          Padding(
            padding: const .symmetric(vertical: 12),
            child: SizedBox(
              width: 30,
              height: 30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: iconColor?.withValues(alpha: .1),
                  borderRadius: .circular(8),
                  border: .all(width: 1.5, color: iconColor ?? Colors.black87),
                ),
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: titleSize ?? 16, color: titleColor, fontWeight: .bold),
          ),
        ],
      ),
    );
  }
}
