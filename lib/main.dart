import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/service_locator.dart';
import 'domain/usecases/get_theme_settings.dart';
import 'domain/usecases/toggle_theme.dart';
import 'domain/usecases/update_accent_color.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  // Load .env if available, but don't crash if it's just an empty placeholder
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Ignore error if file is missing or invalid, as we might be using dart-define
    debugPrint("Could not load .env file: $e");
  }

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Prioritize dart-define (build-time) variables, fallback to dotenv (runtime/asset)
  final baseUrl =
      const String.fromEnvironment('BASE_URL').isNotEmpty
          ? const String.fromEnvironment('BASE_URL')
          : dotenv.env["BASE_URL"] ?? 'http://localhost:8080';

  final wsUrl =
      const String.fromEnvironment('WS_URL').isNotEmpty
          ? const String.fromEnvironment('WS_URL')
          : dotenv.env["WS_URL"] ?? 'ws://localhost:8080/ws/workspace/session';

  // Initialize the service locator with the base URL
  await setupDependencies(baseUrl, wsUrl);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('it')],
      path: 'assets/translations',
      assetLoader: YamlAssetLoader(),
      fallbackLocale: const Locale('en'),
      child: App(
        getThemeSettings: sl<GetThemeSettings>(),
        toggleTheme: sl<ToggleTheme>(),
        updateAccentColor: sl<UpdateAccentColor>(),
      ),
    ),
  );
}
