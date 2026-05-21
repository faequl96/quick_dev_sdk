import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

class QuickSuggestionField<T> extends StatefulWidget {
  const QuickSuggestionField({
    super.key,
    this.decoration = const .fitToTargetWidth(
      yOffset: 6,
      marginY: 14,
      marginX: 14,
      color: Color(0xFFFAFAFA),
      padding: .symmetric(vertical: 8),
      borderRadius: 8,
      border: .fromBorderSide(BorderSide(width: 1, color: Colors.black12)),
      elevation: 1,
      elevationType: .shadow,
      slideTransition: true,
    ),
    this.itemDecoration = const SuggestionItemDecoration(
      padding: .symmetric(horizontal: 10, vertical: 8),
      margin: .symmetric(vertical: 2),
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
  final SuggestionItemDecoration itemDecoration;
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
          targetKey: _key,
          link: _layerLink,
          closeOnTapOutside: false,
          closeOnTapTarget: false,
          decoration: widget.decoration.copyWith(padding: .zero),
          contentBuilder: (_, {bool? isMeasuringWidth}) => Listener(
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
              overlayPadding: widget.decoration.padding,
              itemDecoration: widget.itemDecoration,
              focusNode: _focusNode,
              controller: widget.controller,
              debouncer: widget.debouncer,
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
    required this.overlayPadding,
    required this.itemDecoration,
    required this.focusNode,
    required this.controller,
    required this.debouncer,
    required this.suggestions,
    required this.textStream,
    required this.onSelected,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  final EdgeInsets overlayPadding;
  final SuggestionItemDecoration itemDecoration;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Duration debouncer;
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
      if (widget.loadingBuilder == null) return const SizedBox.shrink();
      return Padding(padding: widget.overlayPadding, child: widget.loadingBuilder!.call(context));
    }

    if (_suggestions.isNotEmpty) {
      return _Suggestions<T>(
        overlayPadding: widget.overlayPadding,
        itemDecoration: widget.itemDecoration,
        onSelected: widget.onSelected,
        suggestions: _suggestions,
        itemBuilder: widget.itemBuilder,
      );
    }

    if (widget.controller.text.isNotEmpty) {
      if (widget.emptyBuilder == null) return const SizedBox.shrink();
      return Padding(padding: widget.overlayPadding, child: widget.emptyBuilder!.call(context));
    }

    return const SizedBox.shrink();
  }
}

class _Suggestions<T> extends StatelessWidget {
  const _Suggestions({
    required this.overlayPadding,
    required this.itemDecoration,
    required this.onSelected,
    required this.suggestions,
    required this.itemBuilder,
  });

  final EdgeInsets overlayPadding;
  final SuggestionItemDecoration itemDecoration;
  final void Function(T value) onSelected;
  final List<T> suggestions;
  final Widget Function(BuildContext context, T value) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollCacheExtent: const .pixels(2),
      padding: overlayPadding,
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) => Padding(
        padding: itemDecoration.margin,
        child: QuickButton(
          onTap: () => onSelected(suggestions[index]),
          style: .lite(
            padding: itemDecoration.padding,
            borderRadius: .circular(itemDecoration.borderRadius),
            color: index % 2 == 1 ? itemDecoration.evenColor : itemDecoration.oddColor,
            hoveredColor: itemDecoration.hoveredColor,
            hoverDuration: const Duration(milliseconds: 100),
            elevation: 0,
          ),
          child: itemBuilder(context, suggestions[index]),
        ),
      ),
    );
  }
}
