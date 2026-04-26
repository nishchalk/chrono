import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/core/utils/relative_time_formatter.dart';

void main() {
  test('past event ends with ago', () {
    final now = DateTime.utc(2026, 4, 26, 12);
    final past = DateTime.utc(2026, 4, 20, 12);
    final s = RelativeTimeFormatter.format(past, now);
    expect(s, endsWith('ago'));
  });

  test('future event starts with in', () {
    final now = DateTime.utc(2026, 4, 26, 12);
    final future = DateTime.utc(2026, 5, 1, 12);
    final s = RelativeTimeFormatter.format(future, now);
    expect(s.startsWith('in '), isTrue);
  });

  test('does not include minutes or seconds in label', () {
    final now = DateTime.utc(2026, 4, 26, 12, 0, 0);
    final past = DateTime.utc(2026, 4, 26, 11, 7, 33);
    final s = RelativeTimeFormatter.format(past, now);
    expect(s, isNot(contains('minute')));
    expect(s, isNot(contains('second')));
  });
}
