import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';

class CategoryTaskSelector extends StatefulWidget {
  final List<CategoryWithTasks> categories;
  final List<Task> orphanTasks;
  final ValueChanged<Category?>? onCategoryChanged;
  final ValueChanged<Task?>? onTaskChanged;

  const CategoryTaskSelector({
    Key? key,
    required this.categories,
    required this.orphanTasks,
    this.onCategoryChanged,
    this.onTaskChanged,
  }) : super(key: key);

  @override
  State<CategoryTaskSelector> createState() => _CategoryTaskSelectorState();
}

class _CategoryTaskSelectorState extends State<CategoryTaskSelector> {
  String? selectedCategory;
  String? selectedTask;

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    tasks = widget.orphanTasks;
  }

  @override
  void didUpdateWidget(CategoryTaskSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tasks when category changes
    if (selectedCategory != null) {
      final category = widget.categories.firstWhere(
        (cat) => cat.category.id == selectedCategory,
        orElse: () => widget.categories.first,
      );
      tasks = category.tasks;
    } else {
      tasks = widget.orphanTasks;
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _clearCategory() {
    setState(() {
      selectedCategory = null;
      selectedTask = null;
      tasks = widget.orphanTasks;
    });

    // Emit changes
    widget.onCategoryChanged?.call(null);
    widget.onTaskChanged?.call(null);
  }

  Category? _getCategoryById(String id) {
    try {
      return widget.categories
          .firstWhere((cat) => cat.category.id == id)
          .category;
    } catch (e) {
      return null;
    }
  }

  Task? _getTaskById(String id) {
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
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
                Icon(Icons.category_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  context.tr('focus.select_category_task'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (selectedCategory != null)
                  IconButton(
                    onPressed: _clearCategory,
                    icon: const Icon(Icons.clear),
                    tooltip: context.tr('focus.clear_selection'),
                    iconSize: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: context.tr('focus.category_label'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.folder_outlined),
                suffixIcon:
                    selectedCategory != null
                        ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _clearCategory,
                        )
                        : null,
              ),
              items:
                  widget.categories.map<DropdownMenuItem<String>>((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.category.id,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _parseColor(cat.category.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(cat.category.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedTask = null;

                  // Update tasks based on selected category
                  if (value != null) {
                    final category = widget.categories.firstWhere(
                      (cat) => cat.category.id == value,
                    );
                    tasks = category.tasks;
                  } else {
                    tasks = widget.orphanTasks;
                  }
                });

                // Emit category change
                final category = value != null ? _getCategoryById(value) : null;
                widget.onCategoryChanged?.call(category);

                // Reset task selection
                widget.onTaskChanged?.call(null);
              },
            ),

            const SizedBox(height: 16),

            // Task dropdown
            DropdownButtonFormField<String>(
              value: selectedTask,
              decoration: InputDecoration(
                labelText: selectedCategory == null ? context.tr('focus.orphan_tasks_label') : context.tr('focus.task_label'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.task_outlined),
                helperText:
                    selectedCategory == null
                        ? context.tr('focus.orphan_tasks_helper')
                        : null,
              ),
              items:
                  tasks.map<DropdownMenuItem<String>>((task) {
                    return DropdownMenuItem<String>(
                      value: task.id,
                      child: Text(task.name),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTask = value;
                });

                final task = value != null ? _getTaskById(value) : null;
                widget.onTaskChanged?.call(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}
