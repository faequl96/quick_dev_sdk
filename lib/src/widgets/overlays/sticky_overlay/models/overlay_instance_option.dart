part of '../sticky_overlay.dart';

sealed class const OverlayInstanceOption() {
  const factory singleton() = _SingletonInstance;

  const factory multiple({required GlobalKey targetKey}) = _MultipleInstance;
}

class const _SingletonInstance() extends OverlayInstanceOption;

class const _MultipleInstance({required final GlobalKey targetKey}) extends OverlayInstanceOption;
