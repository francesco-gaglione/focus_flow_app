import '../repositories/task_repository.dart';

class DeleteTasks {
  final TaskRepository taskRepository;

  DeleteTasks({required this.taskRepository});

  Future<DeleteTasksResult> execute({required List<String> taskIds}) async {
    try {
      // Validate inputs
      if (taskIds.isEmpty) {
        return DeleteTasksResult(
          success: false,
          error: 'Task IDs cannot be empty',
          errorType: DeleteTasksErrorType.validation,
        );
      }

      // Check if all tasks exist
      final existingTasks = await taskRepository.getTasksByIds(taskIds);
      final existingTaskIds = existingTasks.map((task) => task.id).toSet();
      final missingTaskIds =
          taskIds.where((id) => !existingTaskIds.contains(id)).toList();

      if (missingTaskIds.isNotEmpty) {
        return DeleteTasksResult(
          success: false,
          error: 'Some tasks not found: ${missingTaskIds.join(", ")}',
          errorType: DeleteTasksErrorType.notFound,
        );
      }

      // Delete tasks
      final deletedIds = await taskRepository.deleteTasks(taskIds);

      return DeleteTasksResult(success: true, deletedIds: deletedIds);
    } catch (e) {
      return DeleteTasksResult(
        success: false,
        error: e.toString(),
        errorType: DeleteTasksErrorType.internal,
      );
    }
  }
}

enum DeleteTasksErrorType { validation, notFound, internal }

class DeleteTasksResult {
  final bool success;
  final List<String>? deletedIds;
  final String? error;
  final DeleteTasksErrorType? errorType;

  DeleteTasksResult({
    required this.success,
    this.deletedIds,
    this.error,
    this.errorType,
  });
}
