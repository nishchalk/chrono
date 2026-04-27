import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/time_entry.dart';
import '../providers/category_filter_provider.dart';
import '../providers/sort_mode.dart';
import '../providers/sort_mode_provider.dart';
import '../providers/time_entries_notifier.dart';
import '../widgets/time_entry_card.dart';
import 'entry_form_sheet.dart';

List<String> _uniqueSortedCategories(List<TimeEntry> entries) {
  final set = entries.map((e) => e.category.trim()).where((c) => c.isNotEmpty).toSet();
  final out = set.toList()..sort();
  return out;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(timeEntriesNotifierProvider);
    final sort = ref.watch(sortModeProvider);
    final filter = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              semanticLabel: 'Chrono',
            ),
          ),
        ),
        title: const Text('Chrono'),
        actions: [
          entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const SizedBox.shrink();
              }
              final cats = _uniqueSortedCategories(entries);
              if (cats.isEmpty) {
                return const SizedBox.shrink();
              }
              final v = (filter == null || cats.contains(filter)) ? filter : null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: DropdownButton<String?>(
                    isDense: true,
                    isExpanded: true,
                    value: v,
                    icon: const Icon(Icons.filter_list_rounded, size: 20),
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...cats.map(
                        (c) => DropdownMenuItem<String?>(
                          value: c,
                          child: Text(
                            c,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      ref.read(categoryFilterProvider.notifier).state = value;
                    },
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
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
          final cats = _uniqueSortedCategories(entries);
          if (filter != null && !cats.contains(filter)) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              if (ref.read(categoryFilterProvider) == filter) {
                ref.read(categoryFilterProvider.notifier).state = null;
              }
            });
          }
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
          final effective = filter;
          final filtered = effective == null
              ? entries
              : entries.where((e) => e.category.trim() == effective).toList();
          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No entries in this category.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(categoryFilterProvider.notifier).state = null;
                      },
                      child: const Text('Show all'),
                    ),
                  ],
                ),
              ),
            );
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: ListView.separated(
              key: ValueKey('$sort-$filter'),
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 88),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final entry = filtered[index];
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
}
