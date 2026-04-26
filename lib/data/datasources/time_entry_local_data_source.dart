import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../core/constants/database_constants.dart';
import '../../core/constants/entry_defaults.dart';
import '../models/time_entry_model.dart';

/// Low-level SQLite access for entries.
class TimeEntryLocalDataSource {
  TimeEntryLocalDataSource(this._db);

  final sqflite.Database _db;

  /// Opens (or creates) the app SQLite file. Named distinctly from [sqflite.openDatabase].
  static Future<sqflite.Database> openAppDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, DatabaseConstants.fileName);
    return sqflite.openDatabase(
      path,
      version: DatabaseConstants.schemaVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE ${DatabaseConstants.tableEntries} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  event_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  category TEXT NOT NULL DEFAULT '',
  color INTEGER NOT NULL DEFAULT ${EntryDefaults.accentValue}
);
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE ${DatabaseConstants.tableEntries} ADD COLUMN category TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE ${DatabaseConstants.tableEntries} ADD COLUMN color INTEGER NOT NULL DEFAULT ${EntryDefaults.accentValue}",
          );
        }
      },
    );
  }

  Future<List<TimeEntryModel>> getAll() async {
    final rows = await _db.query(
      DatabaseConstants.tableEntries,
      orderBy: 'event_at ASC',
    );
    return rows.map(TimeEntryModel.fromMap).toList();
  }

  Future<int> insert(TimeEntryModel model) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = {
      'title': model.title,
      'event_at': model.eventAtMs,
      'created_at': now,
      'updated_at': now,
      'category': model.category,
      'color': model.color,
    };
    return _db.insert(DatabaseConstants.tableEntries, map);
  }

  Future<void> update(TimeEntryModel model) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.update(
      DatabaseConstants.tableEntries,
      {
        'title': model.title,
        'event_at': model.eventAtMs,
        'updated_at': now,
        'category': model.category,
        'color': model.color,
      },
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.delete(
      DatabaseConstants.tableEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
