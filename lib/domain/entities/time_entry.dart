import '../../core/constants/entry_defaults.dart';

/// Domain entity for a single tracked moment in time (past or future).
class TimeEntry {
  const TimeEntry({
    this.id,
    required this.title,
    required this.eventAt,
    this.category = '',
    this.color = EntryDefaults.accentValue,
  });

  final int? id;
  final String title;
  final DateTime eventAt;

  /// Free-form label (e.g. work, health).
  final String category;

  /// `Color.value` (0xAARRGGBB).
  final int color;

  TimeEntry copyWith({
    int? id,
    String? title,
    DateTime? eventAt,
    String? category,
    int? color,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      eventAt: eventAt ?? this.eventAt,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}
