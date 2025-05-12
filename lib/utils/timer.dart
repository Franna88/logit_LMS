import 'dart:async' as async;

// Simple Timer wrapper to avoid having to import dart:async everywhere
class Timer {
  final Function(Timer) callback;
  final Duration duration;
  async.Timer? _timer;

  Timer.periodic(this.duration, this.callback) {
    _timer = async.Timer.periodic(duration, (_) {
      callback(this);
    });
  }

  void cancel() {
    _timer?.cancel();
  }
}
