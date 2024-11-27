import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class OverlaySuggestionField<T> extends StatefulWidget {
  const OverlaySuggestionField({
    super.key,
    this.width,
    this.height,
    this.decoration,
    this.suggestionItemsBorderRadius = 4,
    this.suggestionItemsPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    this.debouncer = const Duration(milliseconds: 300),
    required this.fieldBuilder,
    required this.controller,
    this.focusNode,
    required this.onSelected,
    required this.suggestions,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  final double? width;
  final double? height;
  final OverlayDecoration? decoration;
  final double suggestionItemsBorderRadius;
  final EdgeInsets? suggestionItemsPadding;
  final Duration debouncer;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) fieldBuilder;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(T value) onSelected;
  final Future<List<T>> Function(String value) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<OverlaySuggestionField<T>> createState() =>
      _OverlaySuggestionFieldState<T>();
}

class _OverlaySuggestionFieldState<T> extends State<OverlaySuggestionField<T>> {
  late FocusNode _focusNode;

  final ShowOverlay _showOverlay = ShowOverlay.instance;
  final GlobalKey _key = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  void Function(String keywords)? _rebuildOnChange;
  void Function(void Function() closeOverlay)? _closeOnFocusRemoved;

  void _onChangeListener() => _rebuildOnChange?.call(widget.controller.text);

  void _onFocusListener() async {
    if (_focusNode.hasPrimaryFocus) {
      _showOverlay.create(
        key: _key,
        linkToTarget: _layerLink,
        slideTransition: false,
        closeOnTapOutside: false,
        decoration: OverlayDecoration(
          color: Colors.transparent,
          border: const Border(),
          boxShadow: const BoxShadow(color: Colors.transparent),
        ),
        yOffset: 10,
        contentBuilder: (_) => _SuggestionsContent(
          decoration: widget.decoration,
          suggestionItemsBorderRadius: widget.suggestionItemsBorderRadius,
          suggestionItemsPadding: widget.suggestionItemsPadding,
          debouncer: widget.debouncer,
          focusNode: _focusNode,
          controller: widget.controller,
          suggestions: widget.suggestions,
          onSelected: widget.onSelected,
          itemBuilder: widget.itemBuilder,
          rebuild: (onChange) => _rebuildOnChange = onChange,
          close: (onFocusRemoved) => _closeOnFocusRemoved = onFocusRemoved,
        ),
      );
    } else {
      _closeOnFocusRemoved?.call(_showOverlay.remove);
    }
  }

  @override
  void initState() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
    }
    widget.controller.addListener(_onChangeListener);
    _focusNode.addListener(_onFocusListener);

    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    widget.controller.dispose();
    _focusNode.removeListener(_onChangeListener);
    widget.focusNode?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        key: _key,
        width: widget.width,
        height: widget.height,
        child: widget.fieldBuilder(context, widget.controller, _focusNode),
      ),
    );
  }
}

class _SuggestionsContent<T> extends StatefulWidget {
  const _SuggestionsContent({
    super.key,
    this.decoration,
    this.suggestionItemsBorderRadius = 4,
    this.suggestionItemsPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    this.debouncer = const Duration(milliseconds: 300),
    required this.focusNode,
    required this.controller,
    required this.suggestions,
    required this.onSelected,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    required this.rebuild,
    required this.close,
  });

  final Duration debouncer;
  final OverlayDecoration? decoration;
  final double suggestionItemsBorderRadius;
  final EdgeInsets? suggestionItemsPadding;
  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(T value) onSelected;
  final Future<List<T>> Function(String value) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final void Function(void Function(String value) onChange) rebuild;
  final void Function(void Function(void Function() value) onFocusRemoved)
      close;

  @override
  State<_SuggestionsContent<T>> createState() => _SuggestionsContentState<T>();
}

class _SuggestionsContentState<T> extends State<_SuggestionsContent<T>> {
  bool _isDispose = false;
  bool _isOnClose = false;

  List<T> _suggestions = [];

  bool _isLoading = false;

  void _setSuggestions(String keywords) async {
    _suggestions.clear();
    if (_isDispose == false && _isOnClose == false) {
      if (keywords.isNotEmpty) _isLoading = true;
      if (_isDispose == false) setState(() {});
      TextInputDebouncer.onChange(
        keywords: keywords,
        duration: const Duration(seconds: 1),
        callBack: () {
          widget.suggestions(keywords).then((value) {
            _suggestions = value;
            _isLoading = false;
            if (_isDispose == false) setState(() {});
          });
        },
      );
      if (keywords.isEmpty) _isLoading = false;
    }
  }

  void _handleCloseOverlay(void Function() closeOverlay) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_isDispose == false) closeOverlay();
  }

  @override
  void initState() {
    widget.rebuild((value) => _setSuggestions(value));
    widget.close((value) => _handleCloseOverlay(value));
    _setSuggestions(widget.controller.text);
    super.initState();
  }

  @override
  void dispose() {
    _isDispose = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_suggestions.isNotEmpty) {
      return CardContainer(
        width: double.maxFinite,
        padding: widget.decoration?.padding ?? EdgeInsets.zero,
        color: widget.decoration?.color ?? Colors.white,
        borderRadius: widget.decoration?.borderRadius ?? 8,
        border: widget.decoration?.border ??
            const Border.fromBorderSide(
              BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
            ),
        boxShadow: widget.decoration?.boxShadow ??
            const BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 2,
              color: Colors.black12,
            ),
        child: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (_, index) {
              return GeneralEffectsButton(
                onTap: () {
                  _isOnClose = true;
                  widget.onSelected(_suggestions[index]);
                },
                padding: widget.suggestionItemsPadding,
                borderRadius: BorderRadius.circular(
                  widget.suggestionItemsBorderRadius,
                ),
                hoveredColor: Colors.grey.shade300,
                splashColor: Colors.grey.shade400,
                hoverDuration: const Duration(milliseconds: 100),
                child: widget.itemBuilder(context, _suggestions[index]),
              );
            },
          ),
        ),
      );
    }
    if (_isLoading) {
      return CardContainer(
        width: double.maxFinite,
        padding: widget.decoration?.padding ?? EdgeInsets.zero,
        color: widget.decoration?.color ?? Colors.white,
        borderRadius: widget.decoration?.borderRadius ?? 8,
        border: widget.decoration?.border ??
            const Border.fromBorderSide(
              BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
            ),
        boxShadow: widget.decoration?.boxShadow ??
            const BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 2,
              color: Colors.black12,
            ),
        child: Padding(
          padding: widget.suggestionItemsPadding ?? EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.loadingBuilder?.call(context) ??
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 24 / 5.4,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                const SizedBox(width: 10),
                const Text("Loading..."),
              ],
            ),
          ),
        ),
      );
    }
    if (widget.controller.text.isNotEmpty) {
      return CardContainer(
        width: double.maxFinite,
        padding: widget.decoration?.padding ?? EdgeInsets.zero,
        color: widget.decoration?.color ?? Colors.white,
        borderRadius: widget.decoration?.borderRadius ?? 8,
        border: widget.decoration?.border ??
            const Border.fromBorderSide(
              BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
            ),
        boxShadow: widget.decoration?.boxShadow ??
            const BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 2,
              color: Colors.black12,
            ),
        child: Padding(
          padding: widget.suggestionItemsPadding ?? EdgeInsets.zero,
          child: widget.emptyBuilder?.call(context) ??
              const Text("Data not found"),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
