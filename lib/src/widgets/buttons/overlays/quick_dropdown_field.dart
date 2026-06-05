import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

List<T> _defaultItemsBuilder<T>({required String keywords}) => [];

class QuickDropdownField<T> extends StatefulWidget {
  const QuickDropdownField({
    super.key,
    required this.onSelected,
    this.height,
    this.width,
    this.fieldTextStyle = const TextStyle(fontSize: 16),
    this.fieldSplashColor,
    required this.fieldDecoration,
    this.overlayDecoration = const .fitToTargetWidth(
      offsetY: 6,
      marginY: 14,
      marginX: 14,
      flipOffset: 80,
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
      useBarrier: false,
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
    this.overlayDecoration = const .fitToTargetWidth(
      offsetY: 6,
      marginY: 14,
      marginX: 14,
      flipOffset: 80,
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
      useBarrier: false,
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
    required List<T> Function({required String keywords}) items,
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
  final OverlayDecoration overlayDecoration;
  final DropdownItemDecoration itemDecoration;
  final bool disabled;
  final T value;
  final String Function(T value) fieldValueBuilder;
  final List<T> _items;
  final List<T> Function({required String keywords}) _itemsBuilder;
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
          decoration: widget.overlayDecoration.copyWith(padding: .zero),
          contentBuilder: (_) {
            if (widget._withItemsSearch) {
              return _DropdownItemsSearch<T>(
                onSelected: widget.onSelected,
                overlayPadding: widget.overlayDecoration.padding,
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
              overlayPadding: widget.overlayDecoration.padding,
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
      overlayInstanceOptionBuilder: (_) => const .singleton(),
      child: Stack(
        children: [
          QuickTextField(
            controller: _textEditingController,
            height: widget.height,
            width: widget.width ?? .maxFinite,
            readOnly: true,
            style: widget.fieldTextStyle,
            decoration: decoration,
          ),
          const Positioned.fill(child: MouseRegion(cursor: SystemMouseCursors.click)),
        ],
      ),
    );
  }
}

class _Dropdowns<T> extends StatefulWidget {
  const _Dropdowns({
    required this.onSelected,
    required this.overlayPadding,
    required this.decoration,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.closeOverlay,
  });

  final void Function(T value) onSelected;
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
  late final ScrollController _controller;

  final _selectedItemKey = GlobalKey();
  int? _selectedIndex;

  double _listViewHeight = 0;
  double _maxScrollExtent = 0;
  double _currentMaxScroll = 0;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();

    _selectedIndex = widget.items.indexOf(widget.value as T);
    if ((_selectedIndex ?? 0) < 0) _selectedIndex = null;

    if (_selectedIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listViewHeight = _controller.position.viewportDimension;
        _maxScrollExtent = _controller.position.maxScrollExtent;
        _autoScrollToSelectedItem();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _autoScrollToSelectedItem() {
    if (!mounted) return;

    final currentContext = _selectedItemKey.currentContext;
    if (currentContext != null) {
      Scrollable.ensureVisible(currentContext, alignment: .2);
      return;
    }

    _currentMaxScroll = (_currentMaxScroll + _listViewHeight).clamp(.0, _maxScrollExtent);
    final currentOffset = _controller.offset;
    if (currentOffset >= _currentMaxScroll) return;

    _controller.jumpTo(_currentMaxScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScrollToSelectedItem());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      scrollCacheExtent: const .pixels(100),
      padding: widget.overlayPadding,
      shrinkWrap: true,
      itemCount: widget.items.length,
      itemBuilder: (_, index) {
        if (widget.items.isEmpty) return const SizedBox.shrink();

        final item = widget.items[index];
        return Padding(
          key: _selectedIndex == index ? _selectedItemKey : null,
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
        );
      },
    );
  }
}

class _DropdownItemsSearch<T> extends StatefulWidget {
  const _DropdownItemsSearch({
    required this.onSelected,
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
  final EdgeInsets overlayPadding;
  final DropdownItemDecoration decoration;
  final T? value;
  final List<T> Function({required String keywords}) items;
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
    _filteredItems = widget.items(keywords: keywords);
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
          padding: const .only(top: 5, left: 5, right: 5, bottom: 5),
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
