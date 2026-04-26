import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits [DateTime.now] immediately, then every minute (relative text has no sub-hour precision in UI).
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  await for (final _ in Stream.periodic(const Duration(minutes: 1))) {
    yield DateTime.now();
  }
});
