import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'domain/usecases/decrement_counter.dart';
import 'domain/usecases/get_counter.dart';
import 'domain/usecases/get_theme_settings.dart';
import 'domain/usecases/increment_counter.dart';
import 'domain/usecases/toggle_theme.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(
    App(
      getCounter: sl<GetCounter>(),
      incrementCounter: sl<IncrementCounter>(),
      decrementCounter: sl<DecrementCounter>(),
      getThemeSettings: sl<GetThemeSettings>(),
      toggleTheme: sl<ToggleTheme>(),
    ),
  );
}
