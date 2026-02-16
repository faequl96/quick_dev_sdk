import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class BottomSheetDialogContent extends StatelessWidget {
  const BottomSheetDialogContent({super.key, this.decoration, this.wallpapers, this.header, required this.contentBuilder});

  final BottomSheetDecoration? decoration;
  final List<Wallpaper>? wallpapers;
  final BottomSheetHeader? header;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;
    final usableHeight = (screenHeight - statusBarHeight) - paddingBottom;

    return SafeArea(
      child: Padding(
        padding: .only(bottom: paddingBottom),
        child: Stack(
          children: [
            if (wallpapers != null) ...wallpapers!,
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: usableHeight),
              child: SizedBox(
                height: decoration?.height,
                width: .maxFinite,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    if (header != null) header!,
                    Flexible(
                      child: decoration?.backgroundContentColor != null
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: decoration?.backgroundContentColor,
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, -3),
                                    color: Colors.black.withValues(alpha: .08),
                                    blurRadius: 3,
                                  ),
                                ],
                                borderRadius: decoration?.borderRadius,
                              ),
                              child: contentBuilder(context),
                            )
                          : contentBuilder(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
