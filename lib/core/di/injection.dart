import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/usecases/calculate_stats_by_period.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/create_manual_session.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/delete_tasks.dart';
import '../../domain/usecases/fetch_orphan_tasks.dart';
import '../../domain/usecases/get_categories_and_tasks.dart';
import '../../domain/usecases/get_sessions_with_filters.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/update_task.dart';
import '../../adapters/repositories/http_category_repository.dart';
import '../../adapters/repositories/http_task_repository.dart';
import '../../adapters/repositories/http_session_repository.dart';
import '../../adapters/repositories/http_statistics_repository.dart';

final getIt = GetIt.instance;

void setupDependencies({String baseUrl = 'http://localhost:3000'}) {
  // Dio
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => HttpCategoryRepository(dio: getIt(), baseUrl: baseUrl),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => HttpTaskRepository(dio: getIt(), baseUrl: baseUrl),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => HttpSessionRepository(dio: getIt(), baseUrl: baseUrl),
  );
  getIt.registerLazySingleton<StatisticsRepository>(
    () => HttpStatisticsRepository(dio: getIt(), baseUrl: baseUrl),
  );

  // Use Cases - Category
  getIt.registerLazySingleton(
    () => GetCategoriesAndTasks(categoryRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateCategory(categoryRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateCategory(categoryRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => DeleteCategory(categoryRepository: getIt()),
  );

  // Use Cases - Task
  getIt.registerLazySingleton(
    () => CreateTask(taskRepository: getIt(), categoryRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateTask(taskRepository: getIt(), categoryRepository: getIt()),
  );
  getIt.registerLazySingleton(() => DeleteTasks(taskRepository: getIt()));
  getIt.registerLazySingleton(() => FetchOrphanTasks(taskRepository: getIt()));

  // Use Cases - Session
  getIt.registerLazySingleton(
    () => GetSessionsWithFilters(sessionRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateManualSession(
      sessionRepository: getIt(),
      taskRepository: getIt(),
      categoryRepository: getIt(),
    ),
  );

  // Use Cases - Statistics
  getIt.registerLazySingleton(
    () => CalculateStatsByPeriod(statisticsRepository: getIt()),
  );
}
