import 'dart:developer';

import 'package:flutter/scheduler.dart';

Future<T> scheduleTask<T>(
    TaskCallback<T> task,
    Priority priority, {
      String debugLabel,
      Flow flow,
    }) {
  final bool isFirstTask = _taskQueue.isEmpty;
  final _TaskEntry<T> entry = _TaskEntry<T>(
    task,
    priority.value,
    debugLabel,
    flow,
  );
  _taskQueue.add(entry);
  if (isFirstTask && !locked)
    _ensureEventLoopCallback();
  return entry.completer.future;
}