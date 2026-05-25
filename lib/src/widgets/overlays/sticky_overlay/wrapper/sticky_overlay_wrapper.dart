part of '../sticky_overlay.dart';

class StickyOverlayWrapper extends StatefulWidget {
  const StickyOverlayWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<StickyOverlayWrapper> createState() => _StickyOverlayWrapperState();
}

class _StickyOverlayWrapperState extends State<StickyOverlayWrapper> {
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
