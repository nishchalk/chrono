/// Calendar-aligned components between two instants (non-negative).
///
/// Computed by advancing [earlier] in whole years, months, and days, then
/// using a wall-clock [Duration] for the remaining sub-day span (handles DST).
class CalendarDurationParts {
  const CalendarDurationParts({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  /// True when every component is zero (same instant).
  bool get isEmpty =>
      years == 0 &&
      months == 0 &&
      days == 0 &&
      hours == 0 &&
      minutes == 0 &&
      seconds == 0;

  /// Builds a breakdown from [earlier] to [later] (must be on or after [earlier]).
  static CalendarDurationParts between(DateTime earlier, DateTime later) {
    assert(!later.isBefore(earlier));

    var cursor = earlier;
    var years = 0;
    while (true) {
      final next = DateTime(
        cursor.year + 1,
        cursor.month,
        cursor.day,
        cursor.hour,
        cursor.minute,
        cursor.second,
        cursor.millisecond,
        cursor.microsecond,
      );
      if (next.isAfter(later)) break;
      years++;
      cursor = next;
    }

    var months = 0;
    while (true) {
      final next = DateTime(
        cursor.year,
        cursor.month + 1,
        cursor.day,
        cursor.hour,
        cursor.minute,
        cursor.second,
        cursor.millisecond,
        cursor.microsecond,
      );
      if (next.isAfter(later)) break;
      months++;
      cursor = next;
    }

    var days = 0;
    while (true) {
      final next = DateTime(
        cursor.year,
        cursor.month,
        cursor.day + 1,
        cursor.hour,
        cursor.minute,
        cursor.second,
        cursor.millisecond,
        cursor.microsecond,
      );
      if (next.isAfter(later)) break;
      days++;
      cursor = next;
    }

    final remainder = later.difference(cursor);
    var hours = remainder.inHours;
    var minutes = remainder.inMinutes.remainder(60);
    var seconds = remainder.inSeconds.remainder(60);

    if (seconds < 0) {
      seconds += 60;
      minutes -= 1;
    }
    if (minutes < 0) {
      minutes += 60;
      hours -= 1;
    }
    if (hours < 0) {
      hours += 24;
      days -= 1;
    }

    return CalendarDurationParts(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}
