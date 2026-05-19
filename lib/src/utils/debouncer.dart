import 'dart:async';

class Debouncer {
  static Timer? _timer;

  static void run(void Function() action, {Duration duration = const Duration(milliseconds: 250)}) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      action();
      _timer?.cancel();
    });
  }
}
