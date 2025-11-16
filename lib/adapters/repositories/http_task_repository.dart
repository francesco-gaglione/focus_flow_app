import 'package:dio/dio.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../dtos/task_dtos.dart';

class HttpTaskRepository implements TaskRepository {
  final Dio _dio;
  final String baseUrl;

  HttpTaskRepository({required Dio dio, this.baseUrl = 'http://localhost:3000'})
    : _dio = dio;

  @override
  Future<List<Task>> getAllTasks() async {
    final response = await _dio.get('$baseUrl/api/tasks');
    final List<dynamic> data = response.data['tasks'];
    return data
        .map(
          (json) => Task(
            id: json['id'],
            name: json['name'],
            description: json['description'],
            categoryId: json['categoryId'],
            scheduledDate: json['scheduledDate'],
            completedAt: json['completedAt'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/api/tasks/$id');
      final json = response.data;
      return Task(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        categoryId: json['categoryId'],
        scheduledDate: json['scheduledDate'],
        completedAt: json['completedAt'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Task>> getTasksByCategoryId(String categoryId) async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.categoryId == categoryId).toList();
  }

  @override
  Future<List<Task>> getOrphanTasks() async {
    final response = await _dio.get('$baseUrl/api/tasks/orphans');
    final dto = OrphanTasksResponseDto.fromJson(response.data);
    return dto.orphanTasks
        .map(
          (task) => Task(
            id: task.id,
            name: task.name,
            description: task.description,
            categoryId: task.categoryId,
            scheduledDate: task.scheduledDate,
            completedAt: task.completedAt,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  @override
  Future<Task> createTask({
    required String name,
    String? description,
    String? categoryId,
    int? scheduledDate,
  }) async {
    final dto = CreateTaskDto(
      name: name,
      description: description,
      categoryId: categoryId,
      scheduledDate: scheduledDate,
    );
    final response = await _dio.post('$baseUrl/api/tasks', data: dto.toJson());
    final responseDto = CreateTaskResponseDto.fromJson(response.data);
    return Task(
      id: responseDto.id,
      name: name,
      description: description,
      categoryId: categoryId,
      scheduledDate: scheduledDate,
      completedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Task> updateTask({
    required String id,
    String? name,
    String? description,
    String? categoryId,
    int? scheduledDate,
    int? completedAt,
  }) async {
    final dto = UpdateTaskDto(
      name: name,
      description: description,
      categoryId: categoryId,
      scheduledDate: scheduledDate,
      completedAt: completedAt,
    );
    final response = await _dio.put(
      '$baseUrl/api/tasks/$id',
      data: dto.toJson(),
    );
    final updated = UpdateTaskResponseDto.fromJson(response.data);
    return Task(
      id: updated.updatedTask.id,
      name: updated.updatedTask.name,
      description: updated.updatedTask.description,
      categoryId: updated.updatedTask.categoryId,
      scheduledDate: updated.updatedTask.scheduledDate,
      completedAt: updated.updatedTask.completedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<String>> deleteTasks(List<String> taskIds) async {
    final dto = DeleteTasksDto(taskIds: taskIds);
    final response = await _dio.delete(
      '$baseUrl/api/tasks',
      data: dto.toJson(),
    );
    final responseDto = DeleteTasksResponseDto.fromJson(response.data);
    return responseDto.deletedIds;
  }

  @override
  Future<bool> taskExistsByName(String name) async {
    final tasks = await getAllTasks();
    return tasks.any((task) => task.name.toLowerCase() == name.toLowerCase());
  }

  @override
  Future<bool> taskExists(String id) async {
    final task = await getTaskById(id);
    return task != null;
  }

  @override
  Future<List<Task>> getTasksByIds(List<String> taskIds) async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => taskIds.contains(task.id)).toList();
  }
}
