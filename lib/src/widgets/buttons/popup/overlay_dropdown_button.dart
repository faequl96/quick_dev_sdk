import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayDropdownButton<T> extends StatelessWidget {
  const OverlayDropdownButton({
    super.key,
    this.parenContext,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.hoveredColor,
    this.splashColor,
    this.useInitialElevation = false,
    this.hoveredElevation,
    this.borderRadius,
    this.border,
    this.clipBehavior = Clip.none,
    this.overlayDynamicWidth = false,
    this.overlayYOffset,
    this.overlayAlignment = OverlayAlign.center,
    this.overlaydecoration,
    this.dropdownItemsBorderRadius = 4,
    this.dropdownItemsPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.disabled = false,
    required this.value,
    required this.dropdownItems,
    required this.dropdownItemBuilder,
    required this.onSelected,
    required this.selectedValueBuilder,
  });

  final BuildContext? parenContext;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? color;
  final Color? hoveredColor;
  final Color? splashColor;
  final bool useInitialElevation;
  final double? hoveredElevation;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Clip clipBehavior;
  final bool overlayDynamicWidth;
  final double? overlayYOffset;
  final OverlayAlign overlayAlignment;
  final OverlayDecoration? overlaydecoration;
  final double dropdownItemsBorderRadius;
  final EdgeInsets? dropdownItemsPadding;
  final bool disabled;
  final T? value;
  final List<T> dropdownItems;
  final Widget Function(T value) dropdownItemBuilder;
  final void Function(T value) onSelected;
  final Widget? Function(T? value) selectedValueBuilder;

  @override
  Widget build(BuildContext context) {
    return OverlayPopupButton(
      width: width,
      height: height,
      padding: padding,
      color: color,
      hoveredColor: hoveredColor,
      splashColor: disabled ? null : splashColor,
      useInitialElevation: useInitialElevation,
      hoveredElevation: hoveredElevation,
      borderRadius: borderRadius,
      border: border,
      clipBehavior: clipBehavior,
      onTap: (handleShowOverlay, closeOverlay) {
        if (disabled) return;
        handleShowOverlay(
          context: parenContext ?? context,
          dynamicWidth: overlayDynamicWidth,
          alignment: overlayAlignment,
          decoration: overlaydecoration?.copyWith(padding: EdgeInsets.zero),
          yOffset: overlayYOffset,
          contentBuilder: (_) => _Dropdowns(
            dropdownItemsBorderRadius: dropdownItemsBorderRadius,
            dropdownItemsPadding: dropdownItemsPadding,
            overlayPadding: overlaydecoration?.padding,
            value: value,
            items: dropdownItems,
            dropdownItemBuilder: dropdownItemBuilder,
            onSelected: onSelected,
            closeOverlay: closeOverlay,
          ),
        );
      },
      child: selectedValueBuilder(value),
    );
  }
}

class _Dropdowns<T> extends StatefulWidget {
  const _Dropdowns({
    required this.dropdownItemsBorderRadius,
    this.dropdownItemsPadding,
    this.overlayPadding,
    this.value,
    required this.items,
    required this.dropdownItemBuilder,
    required this.onSelected,
    required this.closeOverlay,
  });

  final double dropdownItemsBorderRadius;
  final EdgeInsets? dropdownItemsPadding;
  final EdgeInsets? overlayPadding;
  final T? value;
  final List<T> items;
  final Widget Function(T value) dropdownItemBuilder;
  final void Function(T value) onSelected;
  final void Function() closeOverlay;

  @override
  State<_Dropdowns<T>> createState() => _DropdownsState<T>();
}

class _DropdownsState<T> extends State<_Dropdowns<T>> {
  final _listViewKey = GlobalKey();
  double? _listViewHeight;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listViewHeight = (_listViewKey.currentContext?.size?.height ?? 0);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _listViewHeight,
      child: ListView.builder(
        key: _listViewKey,
        padding: widget.overlayPadding,
        shrinkWrap: true,
        cacheExtent: 10,
        itemCount: widget.items.length,
        itemBuilder: (_, index) {
          return GeneralEffectsButton(
            onTap: () async {
              widget.onSelected(widget.items[index]);
              await Future.delayed(const Duration(milliseconds: 120));
              widget.closeOverlay();
            },
            padding: widget.dropdownItemsPadding,
            borderRadius: BorderRadius.circular(widget.dropdownItemsBorderRadius),
            color: widget.items[index] == widget.value ? Colors.grey.shade200 : Colors.transparent,
            hoveredColor: Colors.grey.shade300,
            splashColor: Colors.grey.shade400,
            hoverDuration: const Duration(milliseconds: 100),
            child: widget.dropdownItemBuilder(widget.items[index]),
          );
        },
      ),
    );
  }
}
