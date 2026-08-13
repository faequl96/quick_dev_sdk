import 'dart:async';

class Debouncer({final Duration duration = const Duration(milliseconds: 250)}) {
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
