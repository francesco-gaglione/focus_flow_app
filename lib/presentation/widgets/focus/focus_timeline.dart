import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/category_with_tasks.dart';
import 'package:focus_flow_app/domain/entities/focus_session.dart';
import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/presentation/widgets/focus/session_details_modal.dart';

class FocusTimelineWidget extends StatelessWidget {
  final List<FocusSession> sessions;
  final List<CategoryWithTasks> categories;
  final List<Task> orphanTasks;

  const FocusTimelineWidget({
    super.key,
    this.sessions = const [],
    this.categories = const [],
    this.orphanTasks = const [],
  });

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
                  child: Icon(Icons.timeline, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  context.tr('focus.timeline_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 64,
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('focus.timeline_empty'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final isLast = index == sessions.length - 1;

                  final startTime = DateFormat('HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(session.startedAt * 1000),
                  );
                  final endTime =
                      session.endedAt != null
                          ? DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              session.endedAt! * 1000,
                            ),
                          )
                          : '';
                  final time = '$startTime - $endTime';

                  Category? category;
                  Task? task;
                  String title;
                  Color color;
                  IconData icon;

                  if (session.sessionType == SessionType.work) {
                    if (session.categoryId != null) {
                      try {
                        category =
                            categories
                                .firstWhere(
                                  (CategoryWithTasks c) =>
                                      c.category.id == session.categoryId,
                                )
                                .category;
                      } catch (e) {
                        category = null;
                      }
                    }

                    if (session.taskId != null) {
                      if (category != null) {
                        try {
                          task = categories
                              .firstWhere(
                                (CategoryWithTasks c) =>
                                    c.category.id == session.categoryId,
                              )
                              .tasks
                              .firstWhere((t) => t.id == session.taskId);
                        } catch (e) {
                          task = null;
                        }
                      } else {
                        try {
                          task = orphanTasks.firstWhere(
                            (t) => t.id == session.taskId,
                          );
                        } catch (e) {
                          task = null;
                        }
                      }
                    }

                    title = category?.name ?? 'Uncategorized';
                    color =
                        category != null
                            ? Color(
                              int.parse(
                                category.color.replaceFirst('#', '0xFF'),
                              ),
                            )
                            : Colors.grey;
                    icon = Icons.work;
                  } else if (session.sessionType == SessionType.shortBreak) {
                    title = context.tr('focus.short_break_title');
                    color = Colors.green;
                    icon = Icons.coffee;
                  } else {
                    title = context.tr('focus.long_break_title');
                    color = Colors.blue;
                    icon = Icons.weekend;
                  }

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        color.withOpacity(0.5),
                                        () {
                                          if (sessions[index + 1].sessionType == SessionType.work) {
                                            try {
                                              final nextCategory = categories.firstWhere(
                                                (c) => c.category.id == sessions[index + 1].categoryId,
                                              ).category;
                                              if (nextCategory.color.startsWith('#')) {
                                                return Color(int.parse(nextCategory.color.replaceFirst('#', '0xFF')));
                                              }
                                            } catch (_) {}
                                          }
                                          return Colors.grey;
                                        }().withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // Session card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder:
                                      (context) => SessionDetailsModal(
                                        session: session,
                                        category: category,
                                        task: task,
                                      ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 16,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          time,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (session.concentrationScore != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: color.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.bolt,
                                                  size: 14,
                                                  color: color,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${session.concentrationScore}',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.labelSmall?.copyWith(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            icon,
                                            size: 16,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              if (task != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  task.name,
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodySmall?.copyWith(
                                                        color: colorScheme.onSurfaceVariant,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
