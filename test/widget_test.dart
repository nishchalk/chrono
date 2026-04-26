import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_tracker/app.dart';
import 'package:time_tracker/domain/entities/time_entry.dart';
import 'package:time_tracker/domain/repositories/time_entry_repository.dart';
import 'package:time_tracker/presentation/providers/clock_provider.dart';
import 'package:time_tracker/presentation/providers/dependencies.dart';

/// Avoids opening SQLite in the VM test environment.
class _FakeRepository implements TimeEntryRepository {
  @override
  Future<List<TimeEntry>> getAll() async => [];

  @override
  Future<int> insert(TimeEntry entry) async => 1;

  @override
  Future<void> update(TimeEntry entry) async {}

  @override
  Future<void> delete(int id) async {}
}

void main() {
  testWidgets('Time Tracker shows app bar title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timeEntryRepositoryProvider.overrideWith((ref) async => _FakeRepository()),
          clockProvider.overrideWith((ref) => Stream.value(DateTime.utc(2026, 4, 26, 12))),
        ],
        child: const TimeTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Time Tracker'), findsOneWidget);
  });
}
