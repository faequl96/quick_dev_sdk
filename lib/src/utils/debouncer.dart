class Debouncer<T> {
  late T _stop;

  Future<void> onChange({
    required T value,
    Duration duration = const Duration(milliseconds: 300),
    required void Function() callBack,
  }) async {
    _stop = value;
    await Future<void>.delayed(duration);
    if (_stop == value) callBack();
  }
}
