import 'calendar_duration_parts.dart';

/// Human-readable relative phrases with calendar-aware components.
abstract final class RelativeTimeFormatter {
  /// Example: "2 years 3 months 5 days ago" or "in 4 days 6 hours".
  static String format(DateTime event, DateTime now) {
    if (event.isBefore(now)) {
      final parts = CalendarDurationParts.between(event, now);
      if (parts.isEmpty) return 'Just now';
      return '${_formatParts(parts)} ago';
    }
    if (event.isAtSameMomentAs(now)) {
      return 'Now';
    }
    final parts = CalendarDurationParts.between(now, event);
    if (parts.isEmpty) return 'Now';
    return 'in ${_formatParts(parts)}';
  }

  static String _formatParts(CalendarDurationParts p) {
    final segments = <String>[];
    void add(int value, String singular, String plural) {
      if (value == 0) return;
      segments.add('$value ${value == 1 ? singular : plural}');
    }

    // Only years, months, days, hours (no minutes or seconds in the label).
    add(p.years, 'year', 'years');
    add(p.months, 'month', 'months');
    add(p.days, 'day', 'days');
    add(p.hours, 'hour', 'hours');

    if (segments.isNotEmpty) {
      const maxParts = 4;
      final shown = segments.length > maxParts ? segments.take(maxParts).toList() : segments;
      return shown.join(' ');
    }

    if (p.minutes > 0 || p.seconds > 0) {
      return 'less than 1 hour';
    }
    return 'a moment';
  }
}
