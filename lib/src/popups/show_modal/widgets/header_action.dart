part of '../show_modal.dart';

class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.actionIcon,
    this.iconSize = 28,
    this.onHoverBackgroundColor,
    this.onHoverIconColor,
    required this.onTap,
  });

  static HeaderAction loading({double size = 28}) {
    return HeaderAction(
      actionIcon: Icons.circle_outlined,
      iconSize: size,
      onTap: () {},
    );
  }

  final IconData actionIcon;
  final double iconSize;
  final Color? onHoverBackgroundColor;
  final Color? onHoverIconColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return actionIcon == Icons.circle_outlined
        ? Padding(
            padding: const EdgeInsets.all(2),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: iconSize / 5.4,
                color: Theme.of(context).primaryColor,
              ),
            ),
          )
        : GeneralButton(
            padding: const EdgeInsets.all(2),
            borderRadius: BorderRadius.circular((iconSize + 4) / 2),
            hoveredColor: onHoverBackgroundColor ?? Colors.grey.shade200,
            onTap: () => onTap(),
            onHoverChildBuilder: (value) {
              return Icon(
                actionIcon,
                size: iconSize,
                color: value ? onHoverIconColor : null,
              );
            },
          );
  }
}
