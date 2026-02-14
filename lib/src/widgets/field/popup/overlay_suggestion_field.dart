import 'package:quick_dev_sdk/quick_dev_sdk.dart';
import 'package:flutter/material.dart';

class OverlaySuggestionField<T> extends StatefulWidget {
  const OverlaySuggestionField({
    super.key,
    this.parenContext,
    this.decoration,
    this.suggestionItemDecoration,
    this.debouncer = const Duration(milliseconds: 300),
    required this.fieldBuilder,
    this.dispose = true,
    required this.controller,
    this.focusNode,
    required this.onSelected,
    required this.suggestions,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  final BuildContext? parenContext;
  final OverlayDecoration? decoration;
  final SuggestionItemDecoration? suggestionItemDecoration;
  final Duration debouncer;
  final Widget Function(BuildContext context, TextEditingController controller, FocusNode focusNode) fieldBuilder;
  final bool dispose;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(T value) onSelected;
  final Future<List<T>> Function(String value) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<OverlaySuggestionField<T>> createState() => _OverlaySuggestionFieldState<T>();
}

class _OverlaySuggestionFieldState<T> extends State<OverlaySuggestionField<T>> {
  late FocusNode _focusNode;
  bool _isFocusNodeExternal = false;
  bool _isPointerInsideOverlay = false;
  bool _isOverlayUseInteraction = false;

  final ShowOverlay _showOverlay = ShowOverlay.instance;
  final GlobalKey _key = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  void Function(String keywords)? _rebuildOnChange;
  void Function(void Function() closeOverlay)? _closeOnFocusRemoved;

  void _onChangeListener() => _rebuildOnChange?.call(widget.controller.text);

  void _onFocusListener() async {
    if (_focusNode.hasPrimaryFocus) {
      if (!_isOverlayUseInteraction) {
        _showOverlay.create(
          key: _key,
          linkToTarget: _layerLink,
          context: widget.parenContext ?? context,
          slideTransition: false,
          closeOnTapOutside: false,
          decoration: OverlayDecoration.unStyled(maxHeight: widget.decoration?.maxHeight),
          yOffset: 6,
          contentBuilder: (_) => Listener(
            onPointerDown: (_) {
              _isOverlayUseInteraction = true;
              _isPointerInsideOverlay = true;
            },
            onPointerUp: (_) async {
              await Future.delayed(Duration.zero);
              if (!_isPointerInsideOverlay) return;
              _focusNode.requestFocus();
              _isPointerInsideOverlay = false;
            },
            child: _MainContent(
              decoration: widget.decoration,
              suggestionItemDecoration: widget.suggestionItemDecoration,
              debouncer: widget.debouncer,
              focusNode: _focusNode,
              controller: widget.controller,
              suggestions: widget.suggestions,
              onSelected: (value) {
                widget.onSelected(value);
                _closeOnFocusRemoved?.call(_showOverlay.remove);
                _isPointerInsideOverlay = false;
                _isOverlayUseInteraction = false;
              },
              itemBuilder: widget.itemBuilder,
              rebuild: (onChange) => _rebuildOnChange = onChange,
              close: (onFocusRemoved) => _closeOnFocusRemoved = onFocusRemoved,
              emptyBuilder: widget.emptyBuilder,
              loadingBuilder: widget.loadingBuilder,
            ),
          ),
        );
      }
    } else {
      if (!_isPointerInsideOverlay) {
        _closeOnFocusRemoved?.call(_showOverlay.remove);
        _isOverlayUseInteraction = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isFocusNodeExternal = true;
    } else {
      _focusNode = FocusNode();
    }
    widget.controller.addListener(_onChangeListener);
    _focusNode.addListener(_onFocusListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    _focusNode.removeListener(_onFocusListener);

    if (!_isFocusNodeExternal) _focusNode.dispose();
    if (widget.dispose) widget.controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _key,
      link: _layerLink,
      child: widget.fieldBuilder(context, widget.controller, _focusNode),
    );
  }
}

class _MainContent<T> extends StatefulWidget {
  const _MainContent({
    super.key,
    this.decoration,
    this.suggestionItemDecoration,
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
  final SuggestionItemDecoration? suggestionItemDecoration;
  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(T value) onSelected;
  final Future<List<T>> Function(String value) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final void Function(void Function(String value) onChange) rebuild;
  final void Function(void Function(void Function() value) onFocusRemoved) close;

  @override
  State<_MainContent<T>> createState() => _MainContentState<T>();
}

class _MainContentState<T> extends State<_MainContent<T>> {
  bool _isDispose = false;
  bool _isOnClose = false;

  List<T> _suggestions = [];

  bool _isLoading = false;

  void _setSuggestions(String keywords) {
    _suggestions.clear();
    if (_isDispose == false && _isOnClose == false) {
      if (keywords.isNotEmpty) _isLoading = true;
      if (_isDispose == false) setState(() {});
      TextInputDebouncer.onChange(
        keywords: keywords,
        duration: widget.debouncer,
        callBack: () {
          widget.suggestions(keywords).then((value) {
            _suggestions = [...value];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _isLoading = false;
              if (_isDispose == false) setState(() {});
            });
          });
        },
        onEmptyKeywords: () {
          widget.suggestions(keywords).then((value) {
            _suggestions = [...value];
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
    super.initState();

    widget.rebuild((value) => _setSuggestions(value));
    widget.close((value) => _handleCloseOverlay(value));
    _setSuggestions(widget.controller.text);
  }

  @override
  void dispose() {
    _isDispose = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _defaultCardStyle(widget.loadingBuilder?.call(context) ?? const SizedBox(height: 24));

    if (_suggestions.isNotEmpty) {
      return _Suggestions(
        decoration: widget.decoration,
        suggestionItemDecoration: widget.suggestionItemDecoration,
        onSelected: (value) {
          _isOnClose = true;
          widget.onSelected(value);
        },
        suggestions: _suggestions,
        itemBuilder: widget.itemBuilder,
      );
    }

    if (widget.controller.text.isNotEmpty) {
      if (widget.emptyBuilder == null) return const SizedBox.shrink();
      return _defaultCardStyle(widget.emptyBuilder!(context));
    }

    return const SizedBox.shrink();
  }

  Widget _defaultCardStyle(Widget content) {
    return CardContainer(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      color: widget.decoration?.color ?? Colors.white,
      borderRadius: widget.decoration?.borderRadius ?? 8,
      border: widget.decoration?.border ?? const Border.fromBorderSide(BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
      boxShadow: widget.decoration?.boxShadow ?? const BoxShadow(offset: Offset(0, 3), blurRadius: 2, color: Colors.black12),
      child: content,
    );
  }
}

class _Suggestions<T> extends StatefulWidget {
  const _Suggestions({
    super.key,
    this.decoration,
    this.suggestionItemDecoration,
    required this.onSelected,
    required this.suggestions,
    required this.itemBuilder,
  });

  final OverlayDecoration? decoration;
  final SuggestionItemDecoration? suggestionItemDecoration;
  final void Function(T value) onSelected;
  final List<T> suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;

  @override
  State<_Suggestions<T>> createState() => _SuggestionsState<T>();
}

class _SuggestionsState<T> extends State<_Suggestions<T>> {
  final _listViewKey = GlobalKey();
  final _listViewHeight = ValueNotifier<double?>(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listViewHeight.value = (_listViewKey.currentContext?.size?.height ?? 0) + 2;
    });
  }

  @override
  void dispose() {
    _listViewHeight.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _listViewHeight,
      builder: (_, value, child) {
        return CardContainer(
          height: value,
          width: double.maxFinite,
          color: widget.decoration?.color ?? Colors.white,
          borderRadius: widget.decoration?.borderRadius ?? 8,
          border: widget.decoration?.border ?? const Border.fromBorderSide(BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
          boxShadow: widget.decoration?.boxShadow ?? const BoxShadow(offset: Offset(0, 3), blurRadius: 2, color: Colors.black12),
          clipBehavior: widget.decoration?.clipBehavior ?? Clip.none,
          child: child ?? const SizedBox.shrink(),
        );
      },
      child: ListView.builder(
        key: _listViewKey,
        padding: widget.decoration?.padding,
        shrinkWrap: true,
        cacheExtent: 10,
        itemCount: widget.suggestions.length,
        itemBuilder: (context, index) => GeneralEffectsButton(
          onTap: () => widget.onSelected(widget.suggestions[index]),
          padding: widget.suggestionItemDecoration?.padding,
          borderRadius: BorderRadius.circular(widget.suggestionItemDecoration?.borderRadius ?? 0),
          color: index % 2 == 1
              ? widget.suggestionItemDecoration?.evenColor ?? widget.suggestionItemDecoration?.color ?? Colors.transparent
              : widget.suggestionItemDecoration?.oddColor ?? widget.suggestionItemDecoration?.color ?? Colors.transparent,
          hoveredColor: widget.suggestionItemDecoration?.hoveredColor,
          splashColor: widget.suggestionItemDecoration?.splashColor,
          hoverDuration: const Duration(milliseconds: 100),
          child: widget.itemBuilder(context, widget.suggestions[index]),
        ),
      ),
    );
  }
}

class SuggestionItemDecoration {
  const SuggestionItemDecoration({
    this.padding,
    this.color,
    this.evenColor,
    this.oddColor,
    this.hoveredColor,
    this.splashColor,
    this.borderRadius = 0,
  });

  final EdgeInsets? padding;
  final Color? color;
  final Color? evenColor;
  final Color? oddColor;
  final Color? hoveredColor;
  final Color? splashColor;
  final double borderRadius;
}
