import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/category_repository.dart';

class CreateTask {
  final TaskRepository taskRepository;
  final CategoryRepository categoryRepository;

  CreateTask({required this.taskRepository, required this.categoryRepository});

  Future<CreateTaskResult> execute({
    required String name,
    String? description,
    String? categoryId,
    int? scheduledDate,
  }) async {
    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        return CreateTaskResult(
          success: false,
          error: 'Task name cannot be empty',
          errorType: CreateTaskErrorType.validation,
        );
      }

      // Check if task already exists
      final exists = await taskRepository.taskExistsByName(name);
      if (exists) {
        return CreateTaskResult(
          success: false,
          error: 'Task with this name already exists',
          errorType: CreateTaskErrorType.conflict,
        );
      }

      // Validate category exists if provided
      if (categoryId != null) {
        final categoryExists = await categoryRepository.categoryExists(
          categoryId,
        );
        if (!categoryExists) {
          return CreateTaskResult(
            success: false,
            error: 'Category not found',
            errorType: CreateTaskErrorType.validation,
          );
        }
      }

      // Create task
      final task = await taskRepository.createTask(
        name: name,
        description: description,
        categoryId: categoryId,
        scheduledDate: scheduledDate,
      );

      return CreateTaskResult(success: true, task: task);
    } catch (e) {
      return CreateTaskResult(
        success: false,
        error: e.toString(),
        errorType: CreateTaskErrorType.internal,
      );
    }
  }
}

enum CreateTaskErrorType { validation, conflict, internal }

class CreateTaskResult {
  final bool success;
  final Task? task;
  final String? error;
  final CreateTaskErrorType? errorType;

  CreateTaskResult({
    required this.success,
    this.task,
    this.error,
    this.errorType,
  });
}
