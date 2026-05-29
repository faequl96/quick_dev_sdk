import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

FutureOr<List<T>> _defaultItemsBuilder<T>({required String keywords}) => [];

class QuickDropdownButton<T> extends StatelessWidget {
  const QuickDropdownButton({
    super.key,
    required this.onSelected,
    this.buttonStyle = const QuickButtonStyle(
      splashFactory: InkSparkle.splashFactory,
      hoverDuration: Duration(milliseconds: 250),
      elevation: 1,
      hoveredElevationScale: 1,
      requestFocusOnHover: false,
      clipBehavior: .none,
    ),
    this.overlaydecoration = const .fitToTargetWidth(
      offsetY: 6,
      marginY: 14,
      marginX: 14,
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
    ),
    this.itemDecoration = const DropdownItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      color: Colors.white,
      hoveredColor: Color(0xFFF5F5F5),
      selectedColor: Color(0xFFE0E0E0),
      borderRadius: 0,
    ),
    this.disabled = false,
    required this.value,
    required this._items,
    required this.itemBuilder,
    required this.selectedValueBuilder,
  }) : _withItemsSearch = false,
       _itemsBuilder = _defaultItemsBuilder,
       _searchFieldHeight = 40,
       _searchFieldTextStyle = const TextStyle(),
       _searchFieldDecoration = const FieldDecoration();

  const QuickDropdownButton.withItemsSearch({
    super.key,
    required this.onSelected,
    this.buttonStyle = const QuickButtonStyle(
      splashFactory: InkSparkle.splashFactory,
      hoverDuration: Duration(milliseconds: 250),
      elevation: 1,
      hoveredElevationScale: 1,
      requestFocusOnHover: false,
      clipBehavior: .none,
    ),
    this.overlaydecoration = const .fitToTargetWidth(
      offsetY: 6,
      marginY: 14,
      marginX: 14,
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
    ),
    this.itemDecoration = const DropdownItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      color: Colors.white,
      hoveredColor: Color(0xFFF5F5F5),
      selectedColor: Color(0xFFE0E0E0),
      borderRadius: 0,
    ),
    this.disabled = false,
    required this.value,
    required FutureOr<List<T>> Function({required String keywords}) items,
    required this.itemBuilder,
    required this.selectedValueBuilder,
    this._searchFieldHeight = 40,
    this._searchFieldTextStyle = const TextStyle(fontSize: 14),
    this._searchFieldDecoration = const FieldDecoration(
      contentHorizontalPadding: 4,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black12, width: 1),
        borderRadius: .all(.circular(6)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black12, width: 1),
        borderRadius: .all(.circular(6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black12, width: 1),
        borderRadius: .all(.circular(6)),
      ),
    ),
  }) : _withItemsSearch = true,
       _itemsBuilder = items,
       _items = const [];

  final bool _withItemsSearch;
  final void Function(T value) onSelected;
  final QuickButtonStyle buttonStyle;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final T? value;
  final List<T> _items;
  final FutureOr<List<T>> Function({required String keywords}) _itemsBuilder;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget? Function(BuildContext context, T? value) selectedValueBuilder;
  final double _searchFieldHeight;
  final TextStyle _searchFieldTextStyle;
  final FieldDecoration _searchFieldDecoration;

  @override
  Widget build(BuildContext context) {
    return QuickStickyOverlayButton(
      onTap: (showOverlay, closeOverlay) {
        if (disabled) return;
        showOverlay(
          context,
          decoration: overlaydecoration.copyWith(padding: .zero),
          contentBuilder: (_, {isMeasuringWidth}) {
            if (_withItemsSearch) {
              return _DropdownItemsSearch<T>(
                onSelected: onSelected,
                isMeasuringWidth: isMeasuringWidth,
                overlayPadding: overlaydecoration.padding,
                decoration: itemDecoration,
                value: value,
                items: _itemsBuilder,
                itemBuilder: itemBuilder,
                searchFieldHeight: _searchFieldHeight,
                searchFieldTextStyle: _searchFieldTextStyle,
                searchFieldDecoration: _searchFieldDecoration,
                closeOverlay: closeOverlay,
              );
            }

            return _Dropdowns(
              onSelected: onSelected,
              isMeasuringWidth: isMeasuringWidth,
              overlayPadding: overlaydecoration.padding,
              decoration: itemDecoration,
              value: value,
              items: _items,
              itemBuilder: itemBuilder,
              closeOverlay: closeOverlay,
            );
          },
        );
      },
      buttonStyle: buttonStyle,
      disabled: disabled,
      child: selectedValueBuilder(context, value),
    );
  }
}

class _Dropdowns<T> extends StatelessWidget {
  const _Dropdowns({
    required this.onSelected,
    this.isMeasuringWidth,
    required this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.closeOverlay,
  });

  final void Function(T value) onSelected;
  final bool? isMeasuringWidth;
  final EdgeInsets overlayPadding;
  final DropdownItemDecoration decoration;
  final T? value;
  final List<T> items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final void Function() closeOverlay;

  @override
  Widget build(BuildContext context) {
    final itemCount = isMeasuringWidth == true ? 1 : items.length;

    return ListView.builder(
      scrollCacheExtent: const .pixels(2),
      padding: overlayPadding,
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: decoration.margin,
          child: QuickButton(
            onTap: () {
              closeOverlay();
              onSelected(item);
            },
            style: .lite(
              padding: decoration.padding,
              borderRadius: .circular(decoration.borderRadius),
              color: item == value ? decoration.selectedColor : decoration.color,
              hoveredColor: decoration.hoveredColor,
              hoverDuration: const Duration(milliseconds: 100),
              elevation: 0,
            ),
            child: itemBuilder(context, item),
          ),
        );
      },
    );
  }
}

class _DropdownItemsSearch<T> extends StatefulWidget {
  const _DropdownItemsSearch({
    required this.onSelected,
    this.isMeasuringWidth,
    required this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.searchFieldHeight,
    required this.searchFieldTextStyle,
    required this.searchFieldDecoration,
    required this.closeOverlay,
  });

  final void Function(T value) onSelected;
  final bool? isMeasuringWidth;
  final EdgeInsets overlayPadding;
  final DropdownItemDecoration decoration;
  final T? value;
  final FutureOr<List<T>> Function({required String keywords}) items;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final double searchFieldHeight;
  final TextStyle searchFieldTextStyle;
  final FieldDecoration searchFieldDecoration;
  final void Function() closeOverlay;

  @override
  State<_DropdownItemsSearch<T>> createState() => _DropdownItemsSearchState<T>();
}

class _DropdownItemsSearchState<T> extends State<_DropdownItemsSearch<T>> {
  final _textEditingController = TextEditingController();

  List<T> _filteredItems = [];

  void _onChangeKeywords(String keywords) async {
    _filteredItems = await widget.items(keywords: keywords);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _onChangeKeywords(_textEditingController.text);
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Padding(
          padding: const .only(top: 5, left: 5, right: 5, bottom: 2),
          child: QuickTextField(
            controller: _textEditingController,
            height: 40,
            width: .maxFinite,
            style: widget.searchFieldTextStyle,
            autofocus: true,
            decoration: widget.searchFieldDecoration.copyWith(
              suffixIcons:
                  widget.searchFieldDecoration.suffixIcons ??
                  (controller) => [
                    if (controller.text.isNotEmpty)
                      PreSufFixIcon(
                        onTap: () => controller.clear(),
                        hoveredColor: Colors.grey.shade300,
                        child: const Icon(Icons.close, size: 22),
                      ),
                  ],
            ),
            onChanged: _onChangeKeywords,
          ),
        ),
        Flexible(
          child: _Dropdowns<T>(
            onSelected: widget.onSelected,
            isMeasuringWidth: widget.isMeasuringWidth,
            overlayPadding: widget.overlayPadding,
            decoration: widget.decoration,
            value: widget.value,
            items: _filteredItems,
            itemBuilder: widget.itemBuilder,
            closeOverlay: widget.closeOverlay,
          ),
        ),
      ],
    );
  }
}
