import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../counter/counter_page.dart';
import 'theme_cubit.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (_, state) {
        final themeData =
            state.isDarkMode
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true);

        return MaterialApp(theme: themeData, home: const CounterPage());
      },
    );
  }
}
