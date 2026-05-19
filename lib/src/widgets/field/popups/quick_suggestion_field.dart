import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickSuggestionField<T> extends StatefulWidget {
  const QuickSuggestionField({
    super.key,
    this.decoration = const OverlayDecoration(
      padding: .symmetric(vertical: 8),
      color: Color(0xFFFAFAFA),
      borderRadius: 8,
      elevation: 1,
      elevationType: .elevation,
      clipBehavior: .hardEdge,
    ),
    this.suggestionItemDecoration = const SuggestionItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
      evenColor: Colors.white,
      oddColor: Colors.white,
      hoveredColor: Color(0xFFEEEEEE),
      borderRadius: 0,
    ),
    this.debouncer = const Duration(milliseconds: 250),
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

  final OverlayDecoration decoration;
  final SuggestionItemDecoration suggestionItemDecoration;
  final Duration debouncer;
  final Widget Function(BuildContext context, TextEditingController controller, FocusNode focusNode)
  fieldBuilder;
  final bool dispose;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(T value) onSelected;
  final Future<List<T>> Function(String value) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<QuickSuggestionField<T>> createState() => _QuickSuggestionFieldState<T>();
}

class _QuickSuggestionFieldState<T> extends State<QuickSuggestionField<T>> {
  late final FocusNode _focusNode;
  bool _isFocusNodeExternal = false;
  bool _isPointerInsideOverlay = false;
  bool _isOverlayUseInteraction = false;

  final _overlay = StickyOverlay.instance;
  final _key = GlobalKey();
  final _layerLink = LayerLink();

  final _textStreamController = StreamController<String>.broadcast();

  void _onChangeListener() => _textStreamController.add(widget.controller.text);

  void _onFocusListener() {
    if (_focusNode.hasPrimaryFocus) {
      if (!_isOverlayUseInteraction) {
        _overlay.create(
          context,
          linkKey: _key,
          link: _layerLink,
          slideTransition: false,
          closeOnTapOutside: false,
          closeOnTapLink: false,
          decoration: .unStyled(maxHeight: widget.decoration.maxHeight),
          yOffset: 6,
          contentBuilder: (_) => Listener(
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
            child: _MainContent<T>(
              decoration: widget.decoration,
              suggestionItemDecoration: widget.suggestionItemDecoration,
              debouncer: widget.debouncer,
              focusNode: _focusNode,
              controller: widget.controller,
              suggestions: widget.suggestions,
              textStream: _textStreamController.stream,
              onSelected: (value) {
                widget.onSelected(value);
                _overlay.remove();
                _isPointerInsideOverlay = false;
                _isOverlayUseInteraction = false;
              },
              itemBuilder: widget.itemBuilder,
              emptyBuilder: widget.emptyBuilder,
              loadingBuilder: widget.loadingBuilder,
            ),
          ),
        );
      }
    } else {
      if (!_isPointerInsideOverlay) {
        _overlay.remove();
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
  void didUpdateWidget(covariant QuickSuggestionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChangeListener);
      widget.controller.addListener(_onChangeListener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChangeListener);
    _focusNode.removeListener(_onFocusListener);
    _textStreamController.close();

    if (!_isFocusNodeExternal) _focusNode.dispose();
    if (widget.dispose) widget.controller.dispose();

    _overlay.remove();

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
    required this.decoration,
    required this.suggestionItemDecoration,
    required this.debouncer,
    required this.focusNode,
    required this.controller,
    required this.suggestions,
    required this.textStream,
    required this.onSelected,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  final Duration debouncer;
  final OverlayDecoration decoration;
  final SuggestionItemDecoration suggestionItemDecoration;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Stream<String> textStream;
  final void Function(T value) onSelected;
  final Future<List<T>> Function(String value) suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<_MainContent<T>> createState() => _MainContentState<T>();
}

class _MainContentState<T> extends State<_MainContent<T>> {
  StreamSubscription<String>? _textSubscription;

  List<T> _suggestions = [];
  bool _isLoading = false;

  void _setSuggestions(String keywords) {
    _suggestions.clear();
    if (mounted) {
      if (keywords.isNotEmpty) _isLoading = true;
      if (mounted) setState(() {});
      Debouncer.run(() {
        widget.suggestions(keywords).then((values) {
          _suggestions = values;
          _isLoading = false;
          if (mounted) setState(() {});
        });
      }, duration: widget.debouncer);
    }
  }

  @override
  void initState() {
    super.initState();

    _setSuggestions(widget.controller.text);

    _textSubscription = widget.textStream.listen((keywords) {
      _setSuggestions(keywords);
    });
  }

  @override
  void dispose() {
    _textSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _defaultCardStyle(widget.loadingBuilder?.call(context) ?? const SizedBox(height: 24));
    }

    if (_suggestions.isNotEmpty) {
      return _Suggestions<T>(
        decoration: widget.decoration,
        suggestionItemDecoration: widget.suggestionItemDecoration,
        onSelected: widget.onSelected,
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
    return Container(
      width: .maxFinite,
      padding: const .symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: widget.decoration.color,
        borderRadius: .circular(widget.decoration.borderRadius),
        border: widget.decoration.border,
        boxShadow: DecorationUtils.elevation(
          widget.decoration.elevation,
          elevationType: widget.decoration.elevationType,
        ),
      ),
      child: content,
    );
  }
}

class _Suggestions<T> extends StatelessWidget {
  const _Suggestions({
    required this.decoration,
    required this.suggestionItemDecoration,
    required this.onSelected,
    required this.suggestions,
    required this.itemBuilder,
  });

  final OverlayDecoration decoration;
  final SuggestionItemDecoration suggestionItemDecoration;
  final void Function(T value) onSelected;
  final List<T> suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .maxFinite,
      decoration: BoxDecoration(
        color: decoration.color,
        borderRadius: .circular(decoration.borderRadius),
        border: decoration.border,
        boxShadow: DecorationUtils.elevation(
          decoration.elevation,
          elevationType: decoration.elevationType,
        ),
      ),
      clipBehavior: decoration.clipBehavior,
      child: ListView.builder(
        padding: decoration.padding,
        shrinkWrap: true,
        cacheExtent: 2,
        itemCount: suggestions.length,
        itemBuilder: (context, index) => Padding(
          padding: suggestionItemDecoration.margin,
          child: QuickButton(
            onTap: () => onSelected(suggestions[index]),
            style: QuickButtonStyle.lite(
              padding: suggestionItemDecoration.padding,
              borderRadius: .circular(suggestionItemDecoration.borderRadius),
              color: index % 2 == 1
                  ? suggestionItemDecoration.evenColor
                  : suggestionItemDecoration.oddColor,
              hoveredColor: suggestionItemDecoration.hoveredColor,
              hoverDuration: const Duration(milliseconds: 100),
              elevation: 0,
            ),
            child: itemBuilder(context, suggestions[index]),
          ),
        ),
      ),
    );
  }
}
