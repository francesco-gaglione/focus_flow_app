import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_theme_settings.dart';
import '../../domain/usecases/toggle_theme.dart';
import 'app_view.dart';
import 'theme_cubit.dart';

class App extends StatelessWidget {
  final GetThemeSettings getThemeSettings;
  final ToggleTheme toggleTheme;

  const App({
    super.key,
    required this.getThemeSettings,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ThemeCubit(
            getThemeSettings: getThemeSettings,
            toggleTheme: toggleTheme,
          )..loadTheme(),
      child: const AppView(),
    );
  }
}
