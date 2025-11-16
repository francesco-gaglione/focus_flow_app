import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'domain/usecases/get_theme_settings.dart';
import 'domain/usecases/toggle_theme.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the service locator with the base URL from the environment variable
  await setupDependencies("http://localhost:8080");

  runApp(
    App(
      getThemeSettings: sl<GetThemeSettings>(),
      toggleTheme: sl<ToggleTheme>(),
    ),
  );
}
