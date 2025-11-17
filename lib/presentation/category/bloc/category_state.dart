// State
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/task.dart';

class CategoryState {
  final List<CategoryWithTasksModel> categories;
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<CategoryWithTasksModel>? categories,
    List<Task>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryWithTasksModel {
  final Category category;
  final List<Task> tasks;

  CategoryWithTasksModel({required this.category, required this.tasks});
}
