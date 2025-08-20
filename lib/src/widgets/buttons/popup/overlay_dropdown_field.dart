import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class OverlayDropdownField extends StatefulWidget {
  const OverlayDropdownField({
    super.key,
    this.parenContext,
    this.height,
    this.width,
    this.style = const TextStyle(fontSize: 16),
    this.decoration,
    this.overlayDynamicWidth = false,
    this.overlayYOffset,
    this.overlayAlignment = OverlayAlign.center,
    this.overlaydecoration,
    this.dropdownItemDecoration,
    this.disabled = false,
    required this.value,
    required this.dropdownItems,
    required this.dropdownItemBuilder,
    required this.onSelected,
  });

  final BuildContext? parenContext;
  final double? height;
  final double? width;
  final TextStyle style;
  final FieldDecoration? decoration;
  final bool overlayDynamicWidth;
  final double? overlayYOffset;
  final OverlayAlign overlayAlignment;
  final OverlayDecoration? overlaydecoration;
  final DropdownItemDecoration? dropdownItemDecoration;
  final bool disabled;
  final String? value;
  final List<String> dropdownItems;
  final Widget Function(String value) dropdownItemBuilder;
  final void Function(String value) onSelected;

  @override
  State<OverlayDropdownField> createState() => _OverlayDropdownFieldState();
}

class _OverlayDropdownFieldState extends State<OverlayDropdownField> {
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.text = widget.value ?? '';
  }

  @override
  void didUpdateWidget(covariant OverlayDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);

    _textEditingController.text = widget.value ?? '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPopupButton(
      splashColor: Colors.grey.shade400,
      borderRadius: widget.decoration?.enabledBorder.borderRadius,
      onTap: (handleShowOverlay, closeOverlay) {
        if (widget.disabled) return;
        handleShowOverlay(
          context: widget.parenContext ?? context,
          dynamicWidth: widget.overlayDynamicWidth,
          alignment: widget.overlayAlignment,
          decoration: widget.overlaydecoration?.copyWith(padding: EdgeInsets.zero),
          yOffset: widget.overlayYOffset,
          contentBuilder: (_) => _Dropdowns(
            overlayContentBorderRadius: widget.overlaydecoration?.borderRadius ?? 0,
            overlayPadding: widget.overlaydecoration?.padding,
            decoration: widget.dropdownItemDecoration,
            value: widget.value,
            items: widget.dropdownItems,
            dropdownItemBuilder: widget.dropdownItemBuilder,
            onSelected: widget.onSelected,
            closeOverlay: closeOverlay,
          ),
        );
      },
      child: GeneralTextField(
        controller: _textEditingController,
        height: widget.height,
        width: widget.width,
        enabled: false,
        style: widget.style,
        decoration: widget.decoration,
      ),
    );
  }
}

class _Dropdowns<T> extends StatefulWidget {
  const _Dropdowns({
    required this.overlayContentBorderRadius,
    this.overlayPadding,
    this.decoration,
    this.value,
    required this.items,
    required this.dropdownItemBuilder,
    required this.onSelected,
    required this.closeOverlay,
  });

  final double overlayContentBorderRadius;
  final EdgeInsets? overlayPadding;
  final DropdownItemDecoration? decoration;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.overlayContentBorderRadius),
      child: SizedBox(
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
              padding: widget.decoration?.padding,
              borderRadius: BorderRadius.circular(widget.decoration?.borderRadius ?? 0),
              color: widget.items[index] == widget.value ? widget.decoration?.selectedColor : Colors.transparent,
              hoveredColor: widget.decoration?.hoveredColor,
              splashColor: widget.decoration?.splashColor,
              hoverDuration: const Duration(milliseconds: 100),
              child: widget.dropdownItemBuilder(widget.items[index]),
            );
          },
        ),
      ),
    );
  }
}
