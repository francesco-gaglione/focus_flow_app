import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../focus/focus_page.dart';
import '../category/category_page.dart';
import '../statistics/statistics_page.dart';
import '../settings/settings_page.dart';
import 'main_layout.dart';
import 'theme_cubit.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (_, state) {
        final themeData =
            state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        return MaterialApp.router(theme: themeData, routerConfig: _router);
      },
    );
  }
}

final _router = GoRouter(
  initialLocation: '/focus',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(currentPath: state.uri.path, child: child);
      },
      routes: [
        GoRoute(path: '/focus', builder: (context, state) => const FocusPage()),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatisticsPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
