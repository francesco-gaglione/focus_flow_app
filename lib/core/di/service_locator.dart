import 'package:dio/dio.dart';
import 'package:focus_flow_app/adapters/repositories/http_category_repository.dart';
import 'package:focus_flow_app/adapters/repositories/http_session_repository.dart';
import 'package:focus_flow_app/adapters/repositories/http_statistics_repository.dart';
import 'package:focus_flow_app/adapters/repositories/http_task_repository.dart';
import 'package:focus_flow_app/adapters/ws/ws_repository.dart';
import 'package:focus_flow_app/domain/repositories/category_repository.dart';
import 'package:focus_flow_app/domain/repositories/session_repository.dart';
import 'package:focus_flow_app/domain/repositories/statistics_repository.dart';
import 'package:focus_flow_app/domain/repositories/task_repository.dart';
import 'package:focus_flow_app/domain/usecases/calculate_stats_by_period.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/create_category.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/delete_category.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/update_category.dart';
import 'package:focus_flow_app/domain/usecases/create_manual_session.dart';
import 'package:focus_flow_app/domain/usecases/get_sessions_with_filters.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/create_task.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/delete_tasks.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/fetch_orphan_tasks.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/update_task.dart';
import 'package:get_it/get_it.dart';

import '../../adapters/theme/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/get_theme_settings.dart';
import '../../domain/usecases/toggle_theme.dart';
import '../../domain/usecases/update_accent_color.dart';

final sl = GetIt.instance;

Future<void> setupDependencies(String baseUrl, String wsUrl) async {
  // Dio
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 15),
      ),
    ),
  );

  // Repositories - Theme
  sl.registerLazySingleton<ThemeRepository>(
    () => InMemoryThemeRepositoryImpl(),
  );

  // Repositories - HTTP
  sl.registerLazySingleton<CategoryRepository>(
    () => HttpCategoryRepository(dio: sl(), baseUrl: baseUrl),
  );

  sl.registerLazySingleton<TaskRepository>(
    () => HttpTaskRepository(dio: sl(), baseUrl: baseUrl),
  );

  sl.registerLazySingleton<SessionRepository>(
    () => HttpSessionRepository(dio: sl(), baseUrl: baseUrl),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => HttpStatisticsRepository(dio: sl(), baseUrl: baseUrl),
  );

  // Repositories - WebSocket
  sl.registerLazySingleton<WebsocketRepository>(
    //TODO read ws url from config
    () => WebsocketRepository(wsUrl),
  );

  // Use Cases - Theme
  sl.registerLazySingleton<GetThemeSettings>(
    () => GetThemeSettings(sl<ThemeRepository>()),
  );

  sl.registerLazySingleton<ToggleTheme>(
    () => ToggleTheme(sl<ThemeRepository>()),
  );

  sl.registerLazySingleton<UpdateAccentColor>(
    () => UpdateAccentColor(sl<ThemeRepository>()),
  );

  // Use Cases - Category
  sl.registerLazySingleton<GetCategoriesAndTasks>(
    () => GetCategoriesAndTasks(categoryRepository: sl()),
  );

  sl.registerLazySingleton<CreateCategory>(
    () => CreateCategory(categoryRepository: sl()),
  );

  sl.registerLazySingleton<UpdateCategory>(
    () => UpdateCategory(categoryRepository: sl()),
  );

  sl.registerLazySingleton<DeleteCategory>(
    () => DeleteCategory(categoryRepository: sl()),
  );

  // Use Cases - Task
  sl.registerLazySingleton<CreateTask>(
    () => CreateTask(taskRepository: sl(), categoryRepository: sl()),
  );

  sl.registerLazySingleton<UpdateTask>(
    () => UpdateTask(taskRepository: sl(), categoryRepository: sl()),
  );

  sl.registerLazySingleton<DeleteTasks>(
    () => DeleteTasks(taskRepository: sl()),
  );

  sl.registerLazySingleton<FetchOrphanTasks>(
    () => FetchOrphanTasks(taskRepository: sl()),
  );

  // Use Cases - Session
  sl.registerLazySingleton<GetSessionsWithFilters>(
    () => GetSessionsWithFilters(sessionRepository: sl()),
  );

  sl.registerLazySingleton<CreateManualSession>(
    () => CreateManualSession(
      sessionRepository: sl(),
      taskRepository: sl(),
      categoryRepository: sl(),
    ),
  );

  // Use Cases - Statistics
  sl.registerLazySingleton<CalculateStatsByPeriod>(
    () => CalculateStatsByPeriod(statisticsRepository: sl()),
  );

  // Bloc/Cubit can be registered here as a factory:
  // sl.registerFactory(() => CounterBloc(
  //   getCounter: sl(),
  //   incrementCounter: sl(),
  //   decrementCounter: sl(),
  // ));
}
