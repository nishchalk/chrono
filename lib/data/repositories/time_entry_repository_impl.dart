import '../../domain/entities/time_entry.dart';
import '../../domain/repositories/time_entry_repository.dart';
import '../datasources/time_entry_local_data_source.dart';
import '../models/time_entry_model.dart';

class TimeEntryRepositoryImpl implements TimeEntryRepository {
  TimeEntryRepositoryImpl(this._local);

  final TimeEntryLocalDataSource _local;

  @override
  Future<List<TimeEntry>> getAll() async {
    final rows = await _local.getAll();
    return rows.map((e) => e.toEntity()).toList();
  }

  @override
  Future<int> insert(TimeEntry entry) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final model = TimeEntryModel.fromEntity(entry, createdAtMs: now, updatedAtMs: now);
    return _local.insert(model);
  }

  @override
  Future<void> update(TimeEntry entry) async {
    final id = entry.id;
    if (id == null) {
      throw StateError('Cannot update entry without id');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _local.update(
      TimeEntryModel(
        id: id,
        title: entry.title,
        eventAtMs: entry.eventAt.millisecondsSinceEpoch,
        createdAtMs: now,
        updatedAtMs: now,
        category: entry.category,
        color: entry.color,
      ),
    );
  }

  @override
  Future<void> delete(int id) => _local.delete(id);
}
