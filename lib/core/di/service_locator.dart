import 'package:get_it/get_it.dart';

import '../../adapters/counter/counter_repository_impl.dart';
import '../../adapters/theme/theme_repository_impl.dart';
import '../../domain/repositories/counter_repository.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/get_theme_settings.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/toggle_theme.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Repositories
  sl.registerLazySingleton<CounterRepository>(
    () => InMemoryCounterRepositoryImpl(),
  );

  sl.registerLazySingleton<ThemeRepository>(
    () => InMemoryThemeRepositoryImpl(),
  );

  // Usecases
  sl.registerLazySingleton<GetCounter>(
    () => GetCounter(sl<CounterRepository>()),
  );

  sl.registerLazySingleton<IncrementCounter>(
    () => IncrementCounter(sl<CounterRepository>()),
  );

  sl.registerLazySingleton<DecrementCounter>(
    () => DecrementCounter(sl<CounterRepository>()),
  );

  sl.registerLazySingleton<GetThemeSettings>(
    () => GetThemeSettings(sl<ThemeRepository>()),
  );

  sl.registerLazySingleton<ToggleTheme>(
    () => ToggleTheme(sl<ThemeRepository>()),
  );

  // Bloc/Cubit can be registered here as a factory:
  // sl.registerFactory(() => CounterBloc(
  //   getCounter: sl(),
  //   incrementCounter: sl(),
  //   decrementCounter: sl(),
  // ));
}
