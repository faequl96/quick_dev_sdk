import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class BottomSheetDialogContent extends StatelessWidget {
  const BottomSheetDialogContent({
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
    final paddingBottom = MediaQuery.of(parentContext).viewInsets.bottom;
    final usableHeight = (screenHeight - statusBarHeight) - paddingBottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: paddingBottom),
        child: Stack(
          children: [
            if (wallpapers != null) ...wallpapers!,
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: usableHeight),
              child: SizedBox(
                height: decoration?.height,
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
