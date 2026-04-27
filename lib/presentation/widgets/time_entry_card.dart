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

  static bool _isAnniversaryWeek(DateTime eventAt, DateTime now) {
    // Only entries that already happened can have an anniversary.
    if (eventAt.isAfter(now) || now.year <= eventAt.year) return false;

    final anniversary = _safeAnniversaryDate(eventAt, now.year);
    final start = DateTime(anniversary.year, anniversary.month, anniversary.day);
    final endExclusive = start.add(const Duration(days: 7));
    final today = DateTime(now.year, now.month, now.day);
    return !today.isBefore(start) && today.isBefore(endExclusive);
  }

  static DateTime _safeAnniversaryDate(DateTime source, int year) {
    final lastDayOfMonth = DateTime(year, source.month + 1, 0).day;
    final safeDay = source.day <= lastDayOfMonth ? source.day : lastDayOfMonth;
    return DateTime(year, source.month, safeDay);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockProvider);
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;
    final accent = Color(entry.color);
    final isAnniversaryWeek = _isAnniversaryWeek(entry.eventAt, now);
    final isAccentDark =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark;
    final onAccent = isAccentDark ? Colors.white : Colors.black87;
    final accentSoft = onAccent.withOpacity(0.82);
    final cardBackground =
        isAnniversaryWeek ? accent : scheme.surfaceContainerHighest.withOpacity(0.4);
    final cardBorderColor =
        isAnniversaryWeek ? accent : accent.withOpacity(0.35);
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
            border: Border.all(color: cardBorderColor),
            color: cardBackground,
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
                    color: isAnniversaryWeek ? onAccent.withOpacity(0.95) : accent,
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
                              color: isAnniversaryWeek ? onAccent : null,
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
                                color: isAnniversaryWeek ? accentSoft : accent.withOpacity(0.95),
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
                              color: isAnniversaryWeek ? accentSoft : accent.withOpacity(0.92),
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                      ),
                      Text(
                        exact,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isAnniversaryWeek
                                  ? onAccent.withOpacity(0.72)
                                  : scheme.onSurfaceVariant,
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
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: isAnniversaryWeek ? onAccent.withOpacity(0.92) : scheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
