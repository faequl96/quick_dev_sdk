import 'package:flutter/material.dart';

class ModalDialogContent extends StatefulWidget {
  const ModalDialogContent({super.key, this.header, required this.child});

  final Widget? header;
  final Widget child;

  @override
  State<ModalDialogContent> createState() => _ModalDialogContentState();
}

class _ModalDialogContentState extends State<ModalDialogContent> {
  final GlobalKey _childKey = GlobalKey();

  double childWidth = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        childWidth = _childKey.currentContext?.size?.width ?? 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.header != null && childWidth != 0)
          SizedBox(width: childWidth, child: widget.header),
        Flexible(
          child: ConstrainedBox(
            key: _childKey,
            constraints: const BoxConstraints(minWidth: 280.0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
