import '../entities/time_entry.dart';

/// Persistence contract for time entries (implemented in the data layer).
abstract class TimeEntryRepository {
  Future<List<TimeEntry>> getAll();

  Future<int> insert(TimeEntry entry);

  Future<void> update(TimeEntry entry);

  Future<void> delete(int id);
}
