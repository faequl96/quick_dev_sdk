import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

String _defaultFieldValueBuilder<T>(T value) => value.toString();

class QuickSuggestionField<T> extends StatefulWidget {
  const QuickSuggestionField({
    required this.onSelected,
    super.key,
    this.configuration = const .fitToTargetWidth(
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
    this.itemDecoration = const SuggestionItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      evenColor: Colors.white,
      oddColor: Colors.white,
      hoveredColor: Color(0xFFF5F5F5),
      borderRadius: 0,
    ),
    required this.controller,
    this.focusNode,
    this.debouncer = const Duration(milliseconds: 250),
    required this.fieldBuilder,
    required this.value,
    required this.fieldValueBuilder,
    required this.suggestions,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  }) : _searchOnly = false;

  const QuickSuggestionField.searchOnly({
    required this.onSelected,
    super.key,
    this.configuration = const .fitToTargetWidth(
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
    this.itemDecoration = const SuggestionItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      evenColor: Colors.white,
      oddColor: Colors.white,
      hoveredColor: Color(0xFFF5F5F5),
      borderRadius: 0,
    ),
    required this.controller,
    this.focusNode,
    this.debouncer = const Duration(milliseconds: 250),
    required this.fieldBuilder,
    required this.suggestions,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  }) : _searchOnly = true,
       value = null,
       fieldValueBuilder = _defaultFieldValueBuilder<T>;

  final bool _searchOnly;
  final void Function(T value) onSelected;
  final OverlayConfiguration configuration;
  final SuggestionItemDecoration itemDecoration;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Duration debouncer;
  final Widget Function(BuildContext context, TextEditingController controller, FocusNode focusNode)
  fieldBuilder;
  final T? value;
  final String Function(T value) fieldValueBuilder;
  final Future<List<T>> Function({required String keywords}) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<QuickSuggestionField<T>> createState() => _QuickSuggestionFieldState<T>();
}

class _QuickSuggestionFieldState<T> extends State<QuickSuggestionField<T>> {
  late FocusNode _focusNode;
  bool _isFocusNodeExternal = false;
  bool _isPointerInsideOverlay = false;
  bool _isOverlayUseInteraction = false;

  final _overlay = StickyOverlay();
  final _targetKey = GlobalKey();
  final _layerLink = LayerLink();

  final _textStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    _initFocusNode();
    if (!widget._searchOnly) widget.controller.text = _getDisplayValue();
    widget.controller.addListener(_onChangeListener);
    _focusNode.addListener(_onFocusListener);
  }

  @override
  void didUpdateWidget(covariant QuickSuggestionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChangeListener);
      if (!widget._searchOnly) widget.controller.text = _getDisplayValue();
      widget.controller.addListener(_onChangeListener);
    } else {
      if (!widget._searchOnly) widget.controller.text = _getDisplayValue();
    }

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusListener);
      if (!_isFocusNodeExternal) _focusNode.dispose();
      _initFocusNode();
      _focusNode.addListener(_onFocusListener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    _focusNode.removeListener(_onFocusListener);
    _textStreamController.close();

    if (!_isFocusNodeExternal) _focusNode.dispose();

    _overlay.remove(const .singleton());

    super.dispose();
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isFocusNodeExternal = true;
    } else {
      _focusNode = FocusNode();
      _isFocusNodeExternal = false;
    }
  }

  void _onChangeListener() => _textStreamController.add(widget.controller.text);

  void _onFocusListener() {
    if (_focusNode.hasPrimaryFocus) {
      if (!_isOverlayUseInteraction) {
        _overlay.create(
          context,
          targetKey: _targetKey,
          link: _layerLink,
          closeOnTapOutside: false,
          closeOnTapTarget: false,
          configuration: widget.configuration.copyWith(padding: .zero),
          contentBuilder: (_) {
            return Listener(
              onPointerDown: (_) {
                _isOverlayUseInteraction = true;
                _isPointerInsideOverlay = true;
              },
              onPointerUp: (_) async {
                await Future<void>.delayed(.zero);
                if (!_isPointerInsideOverlay) return;
                _focusNode.requestFocus();
                _isPointerInsideOverlay = false;
              },
              child: _Content<T>(
                onSelected: (value) {
                  _overlay.remove(const .singleton());
                  _isPointerInsideOverlay = false;
                  _isOverlayUseInteraction = false;
                  widget.onSelected(value);
                },
                overlayPadding: widget.configuration.padding,
                itemDecoration: widget.itemDecoration,
                debouncer: widget.debouncer,
                initialKeywords: widget.controller.text,
                suggestions: widget.suggestions,
                textStream: _textStreamController.stream,
                itemBuilder: widget.itemBuilder,
                emptyBuilder: widget.emptyBuilder,
                loadingBuilder: widget.loadingBuilder,
              ),
            );
          },
          onDispose: () {
            if (!mounted) return;
            if (_focusNode.hasFocus && !_isPointerInsideOverlay) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _focusNode.unfocus();
              });
            }
            _isOverlayUseInteraction = false;
          },
        );
      }
    } else {
      if (!_isPointerInsideOverlay) {
        _overlay.remove(const .singleton());
        _isOverlayUseInteraction = false;
      }
    }
  }

  String _getDisplayValue() {
    final currentValue = widget.value;
    if (currentValue == null) return '';
    return widget.fieldValueBuilder(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _targetKey,
      link: _layerLink,
      child: widget.fieldBuilder(context, widget.controller, _focusNode),
    );
  }
}

class _Content<T> extends StatefulWidget {
  const _Content({
    // super.key,
    required this.onSelected,
    required this.overlayPadding,
    required this.itemDecoration,
    required this.debouncer,
    required this.initialKeywords,
    required this.suggestions,
    required this.textStream,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  final void Function(T value) onSelected;
  final EdgeInsets overlayPadding;
  final SuggestionItemDecoration itemDecoration;
  final Duration debouncer;
  final String initialKeywords;
  final Stream<String> textStream;
  final Future<List<T>> Function({required String keywords}) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<_Content<T>> createState() => _ContentState<T>();
}

class _ContentState<T> extends State<_Content<T>> {
  late final Debouncer _debouncer;

  StreamSubscription<String>? _textSubscription;

  List<T> _suggestions = [];
  bool _isLoading = false;

  String _keywords = '';

  void _setSuggestions(String keywords) {
    _keywords = keywords;
    _suggestions.clear();
    if (mounted) {
      if (keywords.isNotEmpty) _isLoading = true;
      if (mounted) setState(() {});
      _debouncer.run(() {
        widget.suggestions(keywords: keywords).then((values) {
          _suggestions = values;
          _isLoading = false;
          if (mounted) setState(() {});
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _debouncer = Debouncer(duration: widget.debouncer);

    _setSuggestions(widget.initialKeywords);
    _textSubscription = widget.textStream.listen((keywords) => _setSuggestions(keywords));
  }

  @override
  void dispose() {
    _textSubscription?.cancel();
    _debouncer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      if (widget.loadingBuilder == null) return const SizedBox.shrink();
      return Padding(padding: widget.overlayPadding, child: widget.loadingBuilder!.call(context));
    }

    if (_suggestions.isNotEmpty) {
      return _Suggestions<T>(
        onSelected: widget.onSelected,
        overlayPadding: widget.overlayPadding,
        itemDecoration: widget.itemDecoration,
        suggestions: _suggestions,
        itemBuilder: widget.itemBuilder,
      );
    }

    if (_keywords.isNotEmpty) {
      if (widget.emptyBuilder == null) return const SizedBox.shrink();
      return Padding(padding: widget.overlayPadding, child: widget.emptyBuilder!.call(context));
    }

    return const SizedBox.shrink();
  }
}

class _Suggestions<T> extends StatelessWidget {
  const _Suggestions({
    required this.onSelected,
    required this.overlayPadding,
    required this.itemDecoration,
    required this.suggestions,
    required this.itemBuilder,
  });

  final void Function(T value) onSelected;
  final EdgeInsets overlayPadding;
  final SuggestionItemDecoration itemDecoration;
  final List<T> suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollCacheExtent: const .pixels(2),
      padding: overlayPadding,
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return Padding(
          padding: itemDecoration.margin,
          child: QuickButton(
            onTap: () => onSelected(suggestion),
            style: .lite(
              padding: itemDecoration.padding,
              borderRadius: .circular(itemDecoration.borderRadius),
              color: index % 2 == 1 ? itemDecoration.evenColor : itemDecoration.oddColor,
              hoveredColor: itemDecoration.hoveredColor,
              hoverDuration: const Duration(milliseconds: 100),
              elevation: 0,
            ),
            child: itemBuilder(context, suggestion),
          ),
        );
      },
    );
  }
}
