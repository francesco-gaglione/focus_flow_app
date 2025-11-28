import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

class FocusNotesWidget extends StatefulWidget {
  final String? initialNotes;
  final ValueChanged<String>? onNotesChanged;

  const FocusNotesWidget({super.key, this.initialNotes, this.onNotesChanged});

  @override
  State<FocusNotesWidget> createState() => _FocusNotesWidgetState();
}

class _FocusNotesWidgetState extends State<FocusNotesWidget> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    _notesController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant FocusNotesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNotes != oldWidget.initialNotes &&
        widget.initialNotes != _notesController.text) {
      _notesController.text = widget.initialNotes ?? '';
    }
  }

  void _onTextChanged() {
    if (widget.onNotesChanged != null) {
      widget.onNotesChanged!(_notesController.text);
    }
  }

  @override
  void dispose() {
    _notesController.removeListener(_onTextChanged);
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  context.tr('focus.notes_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 8,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: context.tr('focus.notes_hint'),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.surface.withOpacity(0.5),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
