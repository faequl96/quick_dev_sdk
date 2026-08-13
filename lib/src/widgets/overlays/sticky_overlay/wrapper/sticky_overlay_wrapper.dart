part of '../sticky_overlay.dart';

class const StickyOverlayWrapper({super.key, required final Widget child}) extends StatefulWidget {
  @override
  State<StickyOverlayWrapper> createState() => _StickyOverlayWrapperState();
}

class _StickyOverlayWrapperState() extends State<StickyOverlayWrapper> {
  late final _entry = OverlayEntry(
    canSizeOverlay: true,
    opaque: true,
    builder: (BuildContext context) => widget.child,
  );

  @override
  void didUpdateWidget(StickyOverlayWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    _entry.markNeedsBuild();
  }

  @override
  void dispose() {
    _entry
      ..remove()
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);
}
