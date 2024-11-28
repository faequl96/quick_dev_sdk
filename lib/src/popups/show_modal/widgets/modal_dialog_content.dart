import 'package:flutter/material.dart';

class ModalDialogContent extends StatefulWidget {
  const ModalDialogContent({
    super.key,
    this.width,
    this.height,
    this.header,
    required this.child,
  });

  final double? width;
  final double? height;
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
      if (widget.width == null) {
        setState(() => childWidth = _childKey.currentContext?.size?.width ?? 0);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.width == null) ...[
            if (widget.header != null && childWidth != 0)
              SizedBox(width: childWidth, child: widget.header),
          ] else ...[
            if (widget.header != null)
              SizedBox(width: double.maxFinite, child: widget.header!)
          ],
          Flexible(
            child: ConstrainedBox(
              key: _childKey,
              constraints: const BoxConstraints(minWidth: 280.0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
