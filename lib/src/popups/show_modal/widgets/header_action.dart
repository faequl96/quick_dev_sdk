part of '../show_modal.dart';

class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.actionIcon,
    this.iconSize = 28,
    this.iconColor,
    this.onHoverIconColor,
    this.onHoverBackgroundColor,
    required this.onTap,
  });

  static HeaderAction loading({double size = 28}) {
    return HeaderAction(actionIcon: Icons.circle_outlined, iconSize: size, onTap: () {});
  }

  final IconData actionIcon;
  final double iconSize;
  final Color? iconColor;
  final Color? onHoverIconColor;
  final Color? onHoverBackgroundColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    if (actionIcon == Icons.circle_outlined) {
      return Padding(
        padding: const .all(2),
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(strokeWidth: iconSize / 5.4, color: Theme.of(context).primaryColor),
        ),
      );
    }
    return GeneralEffectsButton(
      onTap: () => onTap(),
      padding: const .all(2),
      borderRadius: .circular((iconSize + 4) / 2),
      hoveredColor: onHoverBackgroundColor ?? Colors.grey.shade200,
      splashColor: Colors.grey.shade200,
      onHoverChildBuilder: (value) => Icon(actionIcon, size: iconSize, color: value ? onHoverIconColor : iconColor),
    );
  }
}
