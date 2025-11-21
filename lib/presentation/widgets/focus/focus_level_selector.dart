import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

class FocusLevelSelector extends StatefulWidget {
  final ValueChanged<int> onFocusLevelChanged;
  final int? initialLevel;

  const FocusLevelSelector({
    Key? key,
    required this.onFocusLevelChanged,
    this.initialLevel,
  }) : super(key: key);

  @override
  State<FocusLevelSelector> createState() => _FocusLevelSelectorState();
}

class _FocusLevelSelectorState extends State<FocusLevelSelector> {
  int? selectedLevel;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.initialLevel;
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
                Icon(Icons.psychology_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  context.tr('focus.level_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Level selector grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = selectedLevel == level;

                return InkWell(
                  onTap:
                      () => {
                        widget.onFocusLevelChanged(level),
                        setState(() => selectedLevel = level),
                      },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            if (selectedLevel != null) ...[
              const SizedBox(height: 16),
              Text(
                _getLevelDescription(selectedLevel!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getLevelDescription(int level) {
    if (level <= 3) return context.tr('focus.level_low');
    if (level <= 6) return context.tr('focus.level_medium');
    if (level <= 8) return context.tr('focus.level_high');
    return context.tr('focus.level_maximum');
  }
}
