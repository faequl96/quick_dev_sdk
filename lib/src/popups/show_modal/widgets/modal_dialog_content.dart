import 'package:flutter/material.dart';

class ModalDialogContent extends StatefulWidget {
  const ModalDialogContent({
    super.key,
    this.width,
    this.height,
    this.constraints,
    this.padding = .zero,
    this.header,
    required this.child,
  });

  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsets padding;
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
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.width == null) {
        setState(() => childWidth = _childKey.currentContext?.size?.width ?? 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: .min,
        children: [
          if (widget.width == null) ...[
            if (widget.header != null && childWidth != 0) SizedBox(width: childWidth, child: widget.header),
          ] else ...[
            if (widget.header != null) SizedBox(width: .maxFinite, child: widget.header!),
          ],
          Flexible(
            child: ConstrainedBox(
              key: _childKey,
              constraints: widget.constraints ?? const BoxConstraints(minWidth: 280.0),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
