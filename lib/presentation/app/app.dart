import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/get_theme_settings.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/toggle_theme.dart';
import '../counter/counter_bloc.dart';
import 'app_view.dart';
import 'theme_cubit.dart';

class App extends StatelessWidget {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  final DecrementCounter decrementCounter;
  final GetThemeSettings getThemeSettings;
  final ToggleTheme toggleTheme;

  const App({
    super.key,
    required this.getCounter,
    required this.incrementCounter,
    required this.decrementCounter,
    required this.getThemeSettings,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Bloc globale per il tema
        BlocProvider(
          create:
              (_) => ThemeCubit(
                getThemeSettings: getThemeSettings,
                toggleTheme: toggleTheme,
              )..loadTheme(),
        ),
        // Bloc globale per il counter (per semplicità, potresti anche farlo page-level)
        BlocProvider(
          create:
              (_) => CounterBloc(
                getCounter: getCounter,
                incrementCounter: incrementCounter,
                decrementCounter: decrementCounter,
              )..loadCounter(),
        ),
      ],
      child: const AppView(),
    );
  }
}
