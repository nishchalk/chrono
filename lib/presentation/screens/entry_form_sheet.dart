import 'package:flutter/material.dart';

import '../../core/constants/entry_defaults.dart';
import '../../domain/entities/time_entry.dart';

/// Preset colors (ARGB); stored as [TimeEntry.color].
const List<int> _kPalette = [
  0xFF3F51B5,
  0xFF009688,
  0xFFE53935,
  0xFF8E24AA,
  0xFFFF9800,
  0xFF43A047,
  0xFF1E88E5,
  0xFF6D4C41,
  0xFF455A64,
  0xFFFDD835,
  0xFFEC407A,
  0xFF5C6BC0,
];

/// Modal bottom sheet to add or edit an entry with date-time, category, and color.
Future<TimeEntry?> showEntryFormSheet(
  BuildContext context, {
  TimeEntry? initial,
}) {
  return showModalBottomSheet<TimeEntry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _EntryFormBody(initial: initial),
  );
}

class _EntryFormBody extends StatefulWidget {
  const _EntryFormBody({this.initial});

  final TimeEntry? initial;

  @override
  State<_EntryFormBody> createState() => _EntryFormBodyState();
}

class _EntryFormBodyState extends State<_EntryFormBody> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late DateTime _eventAt;
  late int _color;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _categoryController = TextEditingController(text: widget.initial?.category ?? '');
    _eventAt = widget.initial?.eventAt ?? DateTime.now();
    _color = widget.initial?.color ?? EntryDefaults.accentValue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventAt,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _eventAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _eventAt.hour,
          _eventAt.minute,
          _eventAt.second,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventAt),
    );
    if (picked != null) {
      setState(() {
        _eventAt = DateTime(
          _eventAt.year,
          _eventAt.month,
          _eventAt.day,
          picked.hour,
          picked.minute,
          _eventAt.second,
        );
      });
    }
  }

  Future<void> _pickCustomColor() async {
    final base = HSVColor.fromColor(Color(_color));
    var h = base.hue;
    var s = base.saturation;
    const v = 0.9;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Custom color'),
          content: StatefulBuilder(
            builder: (context, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: HSVColor.fromAHSV(1, h, s, v).toColor(),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Hue', style: Theme.of(context).textTheme.labelLarge),
                  Slider(
                    value: h.clamp(0.0, 360.0),
                    max: 360,
                    onChanged: (x) {
                      h = x;
                      setState(() {
                        _color = HSVColor.fromAHSV(1, h, s, v).toColor().value;
                      });
                      setLocal(() {});
                    },
                  ),
                  Text('Saturation', style: Theme.of(context).textTheme.labelLarge),
                  Slider(
                    value: s.clamp(0.0, 1.0),
                    max: 1,
                    onChanged: (x) {
                      s = x;
                      setState(() {
                        _color = HSVColor.fromAHSV(1, h, s, v).toColor().value;
                      });
                      setLocal(() {});
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        );
      },
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    Navigator.of(context).pop(
      TimeEntry(
        id: widget.initial?.id,
        title: title,
        eventAt: _eventAt,
        category: _categoryController.text.trim(),
        color: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewInsetsOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? 'New entry' : 'Edit entry',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Project kickoff',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Work, Health',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: Theme.of(context).textTheme.titleSmall),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _kPalette)
                  _ColorDot(
                    colorValue: v,
                    selected: _color == v,
                    onTap: () => setState(() => _color = v),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: _pickCustomColor,
              icon: const Icon(Icons.palette_outlined, size: 18),
              label: const Text('Custom color'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.calendar_month_rounded, size: 22),
              title: const Text('Date'),
              subtitle: Text(MaterialLocalizations.of(context).formatFullDate(_eventAt)),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.access_time_rounded, size: 22),
              title: const Text('Time'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_eventAt)),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.initial == null ? 'Save entry' : 'Update entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.colorValue,
    required this.selected,
    required this.onTap,
  });

  final int colorValue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Color(colorValue);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(color: c.withOpacity(0.45), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}
