import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';

class FocusState {
  final bool isLoading;
  final String? errorMessage;
  final List<CategoryWithTasks> categories;
  final List<Task> orphanTasks;
  final Category? selectedCategory;
  final Task? selectedTask;

  const FocusState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
    this.orphanTasks = const [],
    this.selectedCategory,
    this.selectedTask,
  });

  FocusState copyWith({
    List<CategoryWithTasks>? categories,
    List<Task>? orphanTasks,
    Category? selectedCategory,
    Task? selectedTask,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearSelectedTask = false,
  }) {
    return FocusState(
      categories: categories ?? this.categories,
      orphanTasks: orphanTasks ?? this.orphanTasks,
      selectedCategory:
          clearSelectedCategory
              ? null
              : selectedCategory ?? this.selectedCategory,
      selectedTask:
          clearSelectedTask ? null : selectedTask ?? this.selectedTask,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
