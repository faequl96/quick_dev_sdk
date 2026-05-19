part of '../floating_overlay.dart';

class BottomSheetContent extends StatelessWidget {
  const BottomSheetContent({
    super.key,
    this.decoration,
    this.wallpapers,
    this.header,
    required this.contentBuilder,
  });

  final BottomSheetDecoration? decoration;
  final List<Wallpaper>? wallpapers;
  final BottomSheetHeader? header;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;
    final paddingBottom = mediaQuery.viewInsets.bottom;
    final usableHeight = (screenHeight - statusBarHeight) - paddingBottom;

    return SafeArea(
      child: Padding(
        padding: .only(bottom: paddingBottom),
        child: Stack(
          children: [
            ...?wallpapers,
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: usableHeight),
              child: SizedBox(
                height: decoration?.height,
                width: .maxFinite,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    ?header,
                    if (decoration?.backgroundContentColor != null)
                      Flexible(
                        child: DecoratedBox(
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
                        ),
                      )
                    else
                      Flexible(child: contentBuilder(context)),
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
