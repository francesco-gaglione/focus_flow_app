import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/theme_settings.dart';
import '../../domain/usecases/get_theme_settings.dart';
import '../../domain/usecases/toggle_theme.dart';

class ThemeState {
  final bool isDarkMode;
  final bool isLoading;

  const ThemeState({required this.isDarkMode, this.isLoading = false});

  ThemeState copyWith({bool? isDarkMode, bool? isLoading}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  final GetThemeSettings _getThemeSettings;
  final ToggleTheme _toggleTheme;

  ThemeCubit({
    required GetThemeSettings getThemeSettings,
    required ToggleTheme toggleTheme,
  }) : _getThemeSettings = getThemeSettings,
       _toggleTheme = toggleTheme,
       super(const ThemeState(isDarkMode: false, isLoading: true));

  Future<void> loadTheme() async {
    emit(state.copyWith(isLoading: true));
    final settings = await _getThemeSettings();
    emit(ThemeState(isDarkMode: settings.isDarkMode, isLoading: false));
  }

  Future<void> toggleTheme() async {
    emit(state.copyWith(isLoading: true));
    final currentSettings = ThemeSettings(isDarkMode: state.isDarkMode);
    final updated = await _toggleTheme(currentSettings);
    emit(ThemeState(isDarkMode: updated.isDarkMode, isLoading: false));
  }
}
