/// Debug tracing for forms_kit.
///
/// Set [formsKitDebug] to true and every lifecycle step in [Form] and
/// [TextFormField] prints a line prefixed `[forms_kit]` with milliseconds
/// since the first line, so the order of focus changes, rebuilds and
/// keyboard actions can be read from the device log.
library;

bool formsKitDebug = false;

final Stopwatch _clock = Stopwatch();

void formsKitLog(String message) {
  if (!formsKitDebug) return;
  if (!_clock.isRunning) _clock.start();
  final ms = _clock.elapsedMilliseconds.toString().padLeft(6);
  // ignore: avoid_print
  print('[forms_kit] $ms ms  $message');
}
