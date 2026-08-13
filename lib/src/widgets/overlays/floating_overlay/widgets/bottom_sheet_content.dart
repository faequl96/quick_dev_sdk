part of '../floating_overlay.dart';

class const BottomSheetContent({
  super.key,
  final BottomSheetDecoration? decoration,
  final List<Wallpaper>? wallpapers,
  final BottomSheetHeader? header,
  required final Widget Function(BuildContext context) contentBuilder,
}) extends StatelessWidget {
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
                width: .infinity,
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
