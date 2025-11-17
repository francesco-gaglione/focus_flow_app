import 'package:focus_flow_app/domain/entities/task.dart';
import 'package:focus_flow_app/domain/repositories/category_repository.dart';
import 'package:focus_flow_app/domain/repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository taskRepository;
  final CategoryRepository categoryRepository;

  UpdateTask({required this.taskRepository, required this.categoryRepository});

  Future<UpdateTaskResult> execute({
    required String id,
    String? name,
    String? description,
    String? categoryId,
    int? scheduledDate,
    int? completedAt,
  }) async {
    try {
      // Check if task exists
      final exists = await taskRepository.taskExists(id);
      if (!exists) {
        return UpdateTaskResult(
          success: false,
          error: 'Task not found',
          errorType: UpdateTaskErrorType.notFound,
        );
      }

      // Validate name if provided
      if (name != null && name.trim().isEmpty) {
        return UpdateTaskResult(
          success: false,
          error: 'Task name cannot be empty',
          errorType: UpdateTaskErrorType.validation,
        );
      }

      // Check if new name conflicts with existing task
      if (name != null) {
        final currentTask = await taskRepository.getTaskById(id);
        if (currentTask != null && currentTask.name != name) {
          final nameExists = await taskRepository.taskExistsByName(name);
          if (nameExists) {
            return UpdateTaskResult(
              success: false,
              error: 'Task with this name already exists',
              errorType: UpdateTaskErrorType.conflict,
            );
          }
        }
      }

      // Validate category exists if provided
      if (categoryId != null) {
        final categoryExists = await categoryRepository.categoryExists(
          categoryId,
        );
        if (!categoryExists) {
          return UpdateTaskResult(
            success: false,
            error: 'Category not found',
            errorType: UpdateTaskErrorType.validation,
          );
        }
      }

      // Update task
      final updatedTask = await taskRepository.updateTask(
        id: id,
        name: name,
        description: description,
        categoryId: categoryId,
        scheduledDate: scheduledDate,
        completedAt: completedAt,
      );

      return UpdateTaskResult(success: true, task: updatedTask);
    } catch (e) {
      return UpdateTaskResult(
        success: false,
        error: e.toString(),
        errorType: UpdateTaskErrorType.internal,
      );
    }
  }
}

enum UpdateTaskErrorType { validation, notFound, conflict, internal }

class UpdateTaskResult {
  final bool success;
  final Task? task;
  final String? error;
  final UpdateTaskErrorType? errorType;

  UpdateTaskResult({
    required this.success,
    this.task,
    this.error,
    this.errorType,
  });
}
