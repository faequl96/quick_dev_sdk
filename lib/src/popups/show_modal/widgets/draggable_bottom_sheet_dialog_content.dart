import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class DraggableBottomSheetDialogContent extends StatelessWidget {
  const DraggableBottomSheetDialogContent({
    super.key,
    required this.parentContext,
    this.decoration,
    this.wallpapers,
    this.header,
    required this.contentBuilder,
  });

  final BuildContext parentContext;
  final BottomSheetDecoration? decoration;
  final List<Wallpaper>? wallpapers;
  final BottomSheetHeader? header;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(parentContext).size.height;
    final statusBarHeight = MediaQuery.of(parentContext).padding.top;
    final usableHeightRatio = (screenHeight - statusBarHeight) / screenHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(parentContext).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: .5,
        maxChildSize: usableHeightRatio,
        expand: false,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [if (wallpapers != null) ...wallpapers!, if (header != null) header!, contentBuilder(context)],
            ),
          );
        },
      ),
    );
  }
}
