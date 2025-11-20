import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'domain/usecases/get_theme_settings.dart';
import 'domain/usecases/toggle_theme.dart';
import 'domain/usecases/update_accent_color.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize the service locator with the base URL from the environment variable
  await setupDependencies("http://localhost:8080");

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('it', 'IT')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: App(
        getThemeSettings: sl<GetThemeSettings>(),
        toggleTheme: sl<ToggleTheme>(),
        updateAccentColor: sl<UpdateAccentColor>(),
      ),
    ),
  );
}
