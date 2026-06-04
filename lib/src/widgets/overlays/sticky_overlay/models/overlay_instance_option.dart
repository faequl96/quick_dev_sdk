part of '../sticky_overlay.dart';

sealed class OverlayInstanceOption {
  const OverlayInstanceOption();

  const factory OverlayInstanceOption.singleton() = _SingletonInstance;

  const factory OverlayInstanceOption.multiple({required GlobalKey targetKey}) = _MultipleInstance;
}

class _SingletonInstance extends OverlayInstanceOption {
  const _SingletonInstance();
}

class _MultipleInstance extends OverlayInstanceOption {
  const _MultipleInstance({required this.targetKey});

  final GlobalKey targetKey;
}
