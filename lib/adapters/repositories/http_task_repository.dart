import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../dtos/task_dtos.dart';

class HttpTaskRepository implements TaskRepository {
  final Dio _dio;
  final String baseUrl;
  final Logger _logger;

  HttpTaskRepository({required Dio dio, this.baseUrl = 'http://localhost:3000'})
    : _dio = dio,
      _logger = Logger(
        printer: SimplePrinter(printTime: true),
        level: kDebugMode ? Level.debug : Level.warning,
      );

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      if (kDebugMode) {
        _logger.d('GET $baseUrl/api/tasks');
      }

      final response = await _dio.get('$baseUrl/api/tasks');

      if (kDebugMode) {
        _logger.d(
          'Response ${response.statusCode}: ${response.data['tasks'].length} tasks',
        );
      }

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
    } catch (e, stackTrace) {
      _logger.e(
        'Failed getAllTasks',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      if (kDebugMode) {
        _logger.d('GET $baseUrl/api/tasks/$id');
      }

      final response = await _dio.get('$baseUrl/api/tasks/$id');
      final json = response.data;

      if (kDebugMode) {
        _logger.d('Response ${response.statusCode}: task ${json['name']}');
      }

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
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 404) {
        _logger.w('Task not found: $id');
        return null;
      }
      _logger.e(
        'Failed getTaskById: $id',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<List<Task>> getOrphanTasks() async {
    try {
      if (kDebugMode) {
        _logger.d('GET $baseUrl/api/tasks/orphans');
      }

      final response = await _dio.get('$baseUrl/api/tasks/orphans');
      final dto = OrphanTasksResponseDto.fromJson(response.data);

      if (kDebugMode) {
        _logger.d(
          'Response ${response.statusCode}: ${dto.orphanTasks.length} orphan tasks',
        );
      }

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
    } catch (e, stackTrace) {
      _logger.e(
        'Failed getOrphanTasks',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<Task> createTask({
    required String name,
    String? description,
    String? categoryId,
    int? scheduledDate,
  }) async {
    try {
      final dto = CreateTaskDto(
        name: name,
        description: description,
        categoryId: categoryId,
        scheduledDate: scheduledDate,
      );

      if (kDebugMode) {
        _logger.d('POST $baseUrl/api/tasks - name: $name');
      }

      final response = await _dio.post(
        '$baseUrl/api/tasks',
        data: dto.toJson(),
      );
      final responseDto = CreateTaskResponseDto.fromJson(response.data);

      if (kDebugMode) {
        _logger.d(
          'Response ${response.statusCode}: task created ${responseDto.id}',
        );
      }

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
    } catch (e, stackTrace) {
      _logger.e(
        'Failed createTask: $name',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
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
    try {
      final dto = UpdateTaskDto(
        name: name,
        description: description,
        categoryId: categoryId,
        scheduledDate: scheduledDate,
        completedAt: completedAt,
      );

      if (kDebugMode) {
        _logger.d('PUT $baseUrl/api/tasks/$id');
      }

      final response = await _dio.put(
        '$baseUrl/api/tasks/$id',
        data: dto.toJson(),
      );
      final updated = UpdateTaskResponseDto.fromJson(response.data);

      if (kDebugMode) {
        _logger.d('Response ${response.statusCode}: task updated');
      }

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
    } catch (e, stackTrace) {
      _logger.e(
        'Failed updateTask: $id',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<List<String>> deleteTasks(List<String> taskIds) async {
    try {
      final dto = DeleteTasksDto(taskIds: taskIds);

      if (kDebugMode) {
        _logger.d('DELETE $baseUrl/api/tasks - count: ${taskIds.length}');
      }

      final response = await _dio.delete(
        '$baseUrl/api/tasks',
        data: dto.toJson(),
      );
      final responseDto = DeleteTasksResponseDto.fromJson(response.data);

      if (kDebugMode) {
        _logger.d(
          'Response ${response.statusCode}: deleted ${responseDto.deletedIds.length} tasks',
        );
      }

      return responseDto.deletedIds;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed deleteTasks',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<bool> taskExistsByName(String name) async {
    try {
      final tasks = await getAllTasks();
      final exists = tasks.any(
        (task) => task.name.toLowerCase() == name.toLowerCase(),
      );

      if (kDebugMode) {
        _logger.d('taskExistsByName "$name": $exists');
      }

      return exists;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed taskExistsByName: $name',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<bool> taskExists(String id) async {
    try {
      final task = await getTaskById(id);
      return task != null;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed taskExists: $id',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }

  @override
  Future<List<Task>> getTasksByIds(List<String> taskIds) async {
    try {
      if (kDebugMode) {
        _logger.d('getTasksByIds count: ${taskIds.length}');
      }

      final allTasks = await getAllTasks();
      final tasks =
          allTasks.where((task) => taskIds.contains(task.id)).toList();

      if (kDebugMode) {
        _logger.d('Found ${tasks.length} tasks by IDs');
      }

      return tasks;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed getTasksByIds',
        error: e,
        stackTrace: kDebugMode ? stackTrace : null,
      );
      rethrow;
    }
  }
}
