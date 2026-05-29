import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

FutureOr<List<T>> _defaultItemsBuilder<T>({required String keywords}) => [];

class QuickDropdownField<T> extends StatefulWidget {
  const QuickDropdownField({
    super.key,
    required this.onSelected,
    this.height,
    this.width,
    this.fieldTextStyle = const TextStyle(fontSize: 16),
    this.fieldSplashColor,
    required this.fieldDecoration,
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
    required this.fieldValueBuilder,
    required this._items,
    required this.itemBuilder,
  }) : _withItemsSearch = false,
       _itemsBuilder = _defaultItemsBuilder,
       _searchFieldHeight = 40,
       _searchFieldTextStyle = const TextStyle(),
       _searchFieldDecoration = const FieldDecoration();

  const QuickDropdownField.withItemsSearch({
    super.key,
    required this.onSelected,
    this.height,
    this.width,
    this.fieldTextStyle = const TextStyle(fontSize: 16),
    this.fieldSplashColor,
    required this.fieldDecoration,
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
    required this.fieldValueBuilder,
    required FutureOr<List<T>> Function({required String keywords}) items,
    required this.itemBuilder,
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
  final double? height;
  final double? width;
  final TextStyle fieldTextStyle;
  final Color? fieldSplashColor;
  final FieldDecoration fieldDecoration;
  final OverlayDecoration overlaydecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final T value;
  final String Function(T value) fieldValueBuilder;
  final List<T> _items;
  final FutureOr<List<T>> Function({required String keywords}) _itemsBuilder;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final double _searchFieldHeight;
  final TextStyle _searchFieldTextStyle;
  final FieldDecoration _searchFieldDecoration;

  @override
  State<QuickDropdownField<T>> createState() => _QuickDropdownFieldState<T>();
}

class _QuickDropdownFieldState<T> extends State<QuickDropdownField<T>> {
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.text = _getDisplayValue();
  }

  @override
  void didUpdateWidget(covariant QuickDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _textEditingController.text = _getDisplayValue();
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  String _getDisplayValue() {
    final currentValue = widget.value;
    if (currentValue == null) return '';
    return widget.fieldValueBuilder(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.fieldDecoration;

    return QuickStickyOverlayButton(
      onTap: (showOverlay, closeOverlay) {
        if (widget.disabled) return;
        showOverlay(
          context,
          decoration: widget.overlaydecoration.copyWith(padding: .zero),
          contentBuilder: (_, {isMeasuringWidth}) {
            // print('tesssssssssss8');
            if (widget._withItemsSearch) {
              return _DropdownItemsSearch<T>(
                onSelected: widget.onSelected,
                isMeasuringWidth: isMeasuringWidth,
                overlayPadding: widget.overlaydecoration.padding,
                decoration: widget.itemDecoration,
                value: widget.value,
                items: widget._itemsBuilder,
                itemBuilder: widget.itemBuilder,
                searchFieldHeight: widget._searchFieldHeight,
                searchFieldTextStyle: widget._searchFieldTextStyle,
                searchFieldDecoration: widget._searchFieldDecoration,
                closeOverlay: closeOverlay,
              );
            }

            return _Dropdowns<T>(
              onSelected: widget.onSelected,
              isMeasuringWidth: isMeasuringWidth,
              overlayPadding: widget.overlaydecoration.padding,
              decoration: widget.itemDecoration,
              value: widget.value,
              items: widget._items,
              itemBuilder: widget.itemBuilder,
              closeOverlay: closeOverlay,
            );
          },
        );
      },
      buttonStyle: QuickButtonStyle(
        height: widget.height,
        width: widget.width,
        splashColor: widget.fieldSplashColor,
        borderRadius: decoration.enabledBorder.borderRadius,
        elevation: 0,
      ),
      child: Stack(
        children: [
          QuickTextField(
            controller: _textEditingController,
            height: widget.height,
            width: widget.width,
            readOnly: true,
            style: widget.fieldTextStyle,
            decoration: decoration,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(height: widget.height, width: widget.width),
          ),
        ],
      ),
    );
  }
}

class _Dropdowns<T> extends StatefulWidget {
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
  State<_Dropdowns<T>> createState() => _DropdownsState<T>();
}

class _DropdownsState<T> extends State<_Dropdowns<T>> {
  ScrollController? _controller;
  final _itemHeightKey = GlobalKey();
  final _scrollKey = GlobalKey();

  final bool _isInitial = true;

  double _itemHeight = 40;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemHeightKey.currentContext != null) {
        _itemHeight = _itemHeightKey.currentContext!.size?.height ?? 40;
      }
    });

    // if (_isInitial && widget.isMeasuringWidth != true) {
    //   print('tessssssssss1');
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (_scrollKey.currentContext != null) {
    //       print('tesssssssss1.2');
    //       final itemHeight = _scrollKey.currentContext!.size?.height ?? 40;
    //       final selectedIndex = widget.items.indexOf(widget.value as T);
    //       print(selectedIndex);
    //       _controller?.jumpTo(selectedIndex * itemHeight);

    //       Scrollable.ensureVisible(_scrollKey.currentContext!, alignment: .2);
    //       _isInitial = false;
    //     }
    //   });
    // }
  }

  // @override
  // void didUpdateWidget(covariant _Dropdowns<T> oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   print(widget.value);
  //   _isInitial = false;

  //   if (_isInitial && widget.items.contains(widget.value) && widget.isMeasuringWidth != true) {
  //     print('tessssssssss2');

  //     print('tessssssssss2.1');
  //     final selectedIndex = widget.items.indexOf(widget.value as T);
  //     print(selectedIndex);
  //     _controller?.jumpTo(selectedIndex * _itemHeight);
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (_scrollKey.currentContext != null) {
  //         print('tessssssssss2.2');

  //         Scrollable.ensureVisible(_scrollKey.currentContext!, alignment: .2);
  //       }
  //     });
  //   }
  // }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.isMeasuringWidth == true ? 1 : widget.items.length;

    return ListView.builder(
      // controller: _controller,
      scrollCacheExtent: const .pixels(200),
      padding: widget.overlayPadding,
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (widget.items.isEmpty) return const SizedBox.shrink();

        final item = widget.items[index];
        return SizedBox(
          // key: index == 0 ? _itemHeightKey : null,
          child: Padding(
            // key: item == widget.value ? _scrollKey : null,
            padding: widget.decoration.margin,
            child: QuickButton(
              onTap: () {
                widget.closeOverlay();
                widget.onSelected(item);
              },
              style: .lite(
                padding: widget.decoration.padding,
                borderRadius: .circular(widget.decoration.borderRadius),
                color: item == widget.value
                    ? widget.decoration.selectedColor
                    : widget.decoration.color,
                hoveredColor: widget.decoration.hoveredColor,
                hoverDuration: const Duration(milliseconds: 100),
                elevation: 0,
              ),
              child: widget.itemBuilder(context, item),
            ),
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

  bool _isInitial = true;

  List<T> _filteredItems = [];

  void _onChangeKeywords(String keywords) async {
    _filteredItems = await widget.items(keywords: keywords);
    // print('tessssssssssss10');
    if (_isInitial) _isInitial = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // print('tesssssssssssss9');

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
        // if (!_isInitial)
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
