import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/relative_time_formatter.dart';
import '../../domain/entities/time_entry.dart';
import '../providers/clock_provider.dart';

/// Dense row for one entry: accent strip, title, category, relative time, exact time.
class TimeEntryCard extends ConsumerWidget {
  const TimeEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final TimeEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static final _exactFormat = DateFormat('MMM d, y • h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockProvider);
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;
    final accent = Color(entry.color);
    final relative = RelativeTimeFormatter.format(entry.eventAt, now);
    final exact = _exactFormat.format(entry.eventAt.toLocal());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.35)),
            color: scheme.surfaceContainerHighest.withOpacity(0.4),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                      ),
                      if (entry.category.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          entry.category.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: accent.withOpacity(0.95),
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        relative,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: accent.withOpacity(0.92),
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                      ),
                      Text(
                        exact,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.1,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: scheme.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
