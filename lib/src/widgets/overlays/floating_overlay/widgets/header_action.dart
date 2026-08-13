part of '../floating_overlay.dart';

class const HeaderAction({
  super.key,
  required final IconData actionIcon,
  final double iconSize = 28,
  final Color? iconColor,
  final Color? onHoverIconColor,
  final Color? onHoverBackgroundColor,
  required final void Function() onTap,
}) extends StatelessWidget {
  static HeaderAction loading({double size = 28}) {
    return HeaderAction(actionIcon: Icons.circle_outlined, iconSize: size, onTap: () {});
  }

  @override
  Widget build(BuildContext context) {
    if (actionIcon == Icons.circle_outlined) {
      return Padding(
        padding: const .all(2),
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: iconSize / 5.4,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return QuickButton(
      onTap: () => onTap(),
      style: QuickButtonStyle(
        padding: const .all(2),
        borderRadius: .circular((iconSize + 4) / 2),
        hoveredColor: onHoverBackgroundColor ?? Colors.grey.shade200,
        splashColor: Colors.grey.shade200,
      ),
      onHoverChildBuilder: (_, value) =>
          Icon(actionIcon, size: iconSize, color: value ? onHoverIconColor : iconColor),
    );
  }
}
