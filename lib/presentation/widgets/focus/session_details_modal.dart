import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/focus_session.dart';
import 'package:focus_flow_app/domain/entities/task.dart';

class SessionDetailsModal extends StatelessWidget {
  final FocusSession session;
  final Category? category;
  final Task? task;

  const SessionDetailsModal({
    super.key,
    required this.session,
    this.category,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWorkSession = session.sessionType == SessionType.work;

    String title;
    Color color;
    IconData icon;

    switch (session.sessionType) {
      case SessionType.work:
        title = category?.name ?? context.tr('focus.session_title');
        color =
            category != null
                ? Color(int.parse(category!.color.replaceFirst('#', '0xFF')))
                : colorScheme.primary;
        icon = Icons.work;
        break;
      case SessionType.shortBreak:
        title = context.tr('focus.short_break_title');
        color = Colors.green;
        icon = Icons.coffee;
        break;
      case SessionType.longBreak:
        title = context.tr('focus.long_break_title');
        color = Colors.blue;
        icon = Icons.weekend;
        break;
    }

    final duration = Duration(
      seconds: session.actualDuration ??
          (session.endedAt != null
              ? (session.endedAt! - session.startedAt) ~/ 1000
              : 0),
    );
    final durationString =
        '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    final startTime = DateFormat('HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(session.startedAt * 1000),
    );
    final endTime =
        session.endedAt != null
            ? DateFormat('HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(session.endedAt! * 1000),
            )
            : '...';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha((255 * 0.1).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isWorkSession && task != null)
                      Text(
                        task!.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildDetailRow(
            context,
            Icons.timer_outlined,
            context.tr('focus.duration_label'),
            durationString,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.access_time,
            context.tr('focus.time_range_label'),
            '$startTime - $endTime',
          ),
          if (session.concentrationScore != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.psychology,
              context.tr('focus.level_badge'),
              session.concentrationScore.toString(),
            ),
          ],
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              context.tr('focus.notes_title'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
