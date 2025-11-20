import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('settings.appearance'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            title: Text(context.tr('settings.dark_mode')),
                            subtitle: Text(
                              state.isDarkMode
                                  ? context.tr('settings.switch_to_light')
                                  : context.tr('settings.switch_to_dark'),
                            ),
                            value: state.isDarkMode,
                            onChanged:
                                state.isLoading
                                    ? null
                                    : (_) {
                                      context.read<ThemeCubit>().toggleTheme();
                                    },
                            secondary: Icon(
                              state.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.tr('settings.accent_color'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                _accentPalette.map((value) {
                                  final color = Color(value);
                                  final isSelected = state.accentColor == value;
                                  return GestureDetector(
                                    onTap:
                                        state.isLoading
                                            ? null
                                            : () => context
                                                .read<ThemeCubit>()
                                                .updateAccentColor(value),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                  : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('settings.about'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(context.tr('settings.version')),
                    subtitle: const Text('1.0.0'),
                    leading: const Icon(Icons.code),
                  ),
                  ListTile(
                    title: Text(context.tr('settings.app_name')),
                    subtitle: Text(context.tr('settings.app_description')),
                    leading: const Icon(Icons.timer),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<int> _accentPalette = [
  0xFF6750A4,
  0xFF625B71,
  0xFFB3261E,
  0xFF386A20,
  0xFF006874,
  0xFF4F378B,
  0xFF7D5260,
];
