part of '../floating_overlay.dart';

class const DialogContent({
  super.key,
  final double? width,
  final double? height,
  final BoxConstraints? constraints,
  final EdgeInsets padding = .zero,
  final Widget? header,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<DialogContent> createState() => _DialogContentState();
}

class _DialogContentState() extends State<DialogContent> {
  final _childKey = GlobalKey();

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
            if (widget.header != null && childWidth != 0)
              SizedBox(width: childWidth, child: widget.header),
          ] else ...[
            if (widget.header != null) SizedBox(width: .infinity, child: widget.header!),
          ],
          Flexible(
            child: ConstrainedBox(
              key: _childKey,
              constraints: widget.constraints ?? const BoxConstraints(minWidth: 280),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
