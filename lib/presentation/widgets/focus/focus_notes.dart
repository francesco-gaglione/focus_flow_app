import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

class FocusNotesWidget extends StatefulWidget {
  const FocusNotesWidget({Key? key}) : super(key: key);

  @override
  State<FocusNotesWidget> createState() => _FocusNotesWidgetState();
}

class _FocusNotesWidgetState extends State<FocusNotesWidget> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  context.tr('focus.notes_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: context.tr('focus.notes_hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
