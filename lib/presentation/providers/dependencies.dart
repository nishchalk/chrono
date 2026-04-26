import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/time_entry_local_data_source.dart';
import '../../data/repositories/time_entry_repository_impl.dart';
import '../../domain/repositories/time_entry_repository.dart';

/// Opens the SQLite database once and disposes it when the provider graph is torn down.
final databaseProvider = FutureProvider<Database>((ref) async {
  final db = await TimeEntryLocalDataSource.openAppDatabase();
  ref.onDispose(db.close);
  return db;
});

final timeEntryLocalDataSourceProvider = FutureProvider<TimeEntryLocalDataSource>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TimeEntryLocalDataSource(db);
});

final timeEntryRepositoryProvider = FutureProvider<TimeEntryRepository>((ref) async {
  final ds = await ref.watch(timeEntryLocalDataSourceProvider.future);
  return TimeEntryRepositoryImpl(ds);
});
