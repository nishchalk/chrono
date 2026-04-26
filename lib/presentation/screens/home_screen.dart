import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/time_entry.dart';
import '../providers/sort_mode.dart';
import '../providers/sort_mode_provider.dart';
import '../providers/time_entries_notifier.dart';
import '../widgets/time_entry_card.dart';
import 'entry_form_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, TimeEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text('Remove “${entry.title}”? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && entry.id != null && context.mounted) {
      await ref.read(timeEntriesNotifierProvider.notifier).deleteById(entry.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(timeEntriesNotifierProvider);
    final sort = ref.watch(sortModeProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text('Time Tracker'),
        actions: [
          PopupMenuButton<SortMode>(
            tooltip: 'Sort',
            initialValue: sort,
            onSelected: (mode) => ref.read(sortModeProvider.notifier).state = mode,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortMode.closestUpcoming,
                child: Text('Closest upcoming'),
              ),
              PopupMenuItem(
                value: SortMode.mostRecentPast,
                child: Text('Most recent past'),
              ),
            ],
            icon: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No entries yet.\nTap + to add a moment in time.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: ListView.separated(
              key: ValueKey(sort),
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 88),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return TimeEntryCard(
                  key: ValueKey(entry.id),
                  entry: entry,
                  onEdit: () async {
                    final updated = await showEntryFormSheet(context, initial: entry);
                    if (updated != null && context.mounted) {
                      await ref.read(timeEntriesNotifierProvider.notifier).updateEntry(updated);
                    }
                  },
                  onDelete: () => _confirmDelete(context, ref, entry),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load entries.\n$e')),
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Add entry',
        onPressed: () async {
          final created = await showEntryFormSheet(context);
          if (created != null && context.mounted) {
            await ref.read(timeEntriesNotifierProvider.notifier).add(created);
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
