import 'package:equatable/equatable.dart';
import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/domain/repositories/category_repository.dart';

class GetCategoriesAndTasks {
  final CategoryRepository categoryRepository;

  GetCategoriesAndTasks({required this.categoryRepository});

  Future<GetCategoriesAndTasksResult> execute() async {
    try {
      final categories = await categoryRepository.getAllCategories();

      // Get tasks for each category
      final categoriesWithTasks = <CategoryWithTasks>[];

      for (final category in categories) {
        final tasks = await categoryRepository.getTasksByCategoryId(
          category.id,
        );
        categoriesWithTasks.add(
          CategoryWithTasks(category: category, tasks: tasks),
        );
      }

      return GetCategoriesAndTasksResult(
        success: true,
        categoriesWithTasks: categoriesWithTasks,
      );
    } catch (e) {
      return GetCategoriesAndTasksResult(success: false, error: e.toString());
    }
  }
}

class CategoryWithTasks extends Equatable {
  final Category category;
  final List<Task> tasks;

  const CategoryWithTasks({required this.category, required this.tasks});

  @override
  List<Object?> get props => [category, tasks];
}

class GetCategoriesAndTasksResult {
  final bool success;
  final List<CategoryWithTasks>? categoriesWithTasks;
  final String? error;

  GetCategoriesAndTasksResult({
    required this.success,
    this.categoriesWithTasks,
    this.error,
  });
}
