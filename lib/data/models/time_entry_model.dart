import '../../core/constants/entry_defaults.dart';
import '../../domain/entities/time_entry.dart';

/// Row mapping for SQLite.
class TimeEntryModel {
  const TimeEntryModel({
    required this.id,
    required this.title,
    required this.eventAtMs,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.category,
    required this.color,
  });

  final int id;
  final String title;
  final int eventAtMs;
  final int createdAtMs;
  final int updatedAtMs;
  final String category;
  final int color;

  factory TimeEntryModel.fromEntity(TimeEntry e, {required int createdAtMs, required int updatedAtMs}) {
    return TimeEntryModel(
      id: e.id ?? 0,
      title: e.title,
      eventAtMs: e.eventAt.millisecondsSinceEpoch,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      category: e.category,
      color: e.color,
    );
  }

  factory TimeEntryModel.fromMap(Map<String, Object?> map) {
    return TimeEntryModel(
      id: map['id']! as int,
      title: map['title']! as String,
      eventAtMs: map['event_at']! as int,
      createdAtMs: map['created_at']! as int,
      updatedAtMs: map['updated_at']! as int,
      category: (map['category'] as String?) ?? '',
      color: (map['color'] as int?) ?? EntryDefaults.accentValue,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != 0) 'id': id,
      'title': title,
      'event_at': eventAtMs,
      'created_at': createdAtMs,
      'updated_at': updatedAtMs,
      'category': category,
      'color': color,
    };
  }

  TimeEntry toEntity() {
    return TimeEntry(
      id: id,
      title: title,
      eventAt: DateTime.fromMillisecondsSinceEpoch(eventAtMs),
      category: category,
      color: color,
    );
  }
}
