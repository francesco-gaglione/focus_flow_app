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
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize the service locator with the base URL from the environment variable
  await setupDependencies(dotenv.env["BASE_URL"]!, dotenv.env["WS_URL"]!);

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
