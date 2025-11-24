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
                    subtitle: const Text('0.0.1-alpha.1'),
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
