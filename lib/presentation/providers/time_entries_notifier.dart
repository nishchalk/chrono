import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/time_entry.dart';
import '../../domain/repositories/time_entry_repository.dart';
import 'dependencies.dart';
import 'sort_mode.dart';
import 'sort_mode_provider.dart';

/// Applies the active [SortMode] using a single reference instant.
List<TimeEntry> sortedEntries(List<TimeEntry> all, SortMode mode, DateTime now) {
  final past = all.where((e) => !e.eventAt.isAfter(now)).toList();
  final future = all.where((e) => e.eventAt.isAfter(now)).toList();

  switch (mode) {
    case SortMode.closestUpcoming:
      future.sort((a, b) => a.eventAt.compareTo(b.eventAt));
      past.sort((a, b) => b.eventAt.compareTo(a.eventAt));
      return [...future, ...past];
    case SortMode.mostRecentPast:
      past.sort((a, b) => b.eventAt.compareTo(a.eventAt));
      future.sort((a, b) => a.eventAt.compareTo(b.eventAt));
      return [...past, ...future];
  }
}

final timeEntriesNotifierProvider =
    AsyncNotifierProvider<TimeEntriesNotifier, List<TimeEntry>>(TimeEntriesNotifier.new);

class TimeEntriesNotifier extends AsyncNotifier<List<TimeEntry>> {
  @override
  Future<List<TimeEntry>> build() async {
    final repo = await ref.watch(timeEntryRepositoryProvider.future);
    final sort = ref.watch(sortModeProvider);
    final list = await repo.getAll();
    return sortedEntries(list, sort, DateTime.now());
  }

  Future<TimeEntryRepository> _repo() => ref.read(timeEntryRepositoryProvider.future);

  Future<void> add(TimeEntry entry) async {
    final repo = await _repo();
    await repo.insert(entry);
    ref.invalidateSelf();
  }

  Future<void> updateEntry(TimeEntry entry) async {
    final repo = await _repo();
    await repo.update(entry);
    ref.invalidateSelf();
  }

  Future<void> deleteById(int id) async {
    final repo = await _repo();
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
