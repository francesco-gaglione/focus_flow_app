import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/locale_cubit.dart';
import '../app/theme_cubit.dart';
import '../../domain/usecases/get_app_version.dart';
import '../../core/di/service_locator.dart';

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
                          ListTile(
                            title: Text(context.tr('settings.language')),
                            subtitle: Text(
                              context.locale.languageCode == 'en'
                                  ? context.tr('settings.english')
                                  : context.tr('settings.italian'),
                            ),
                            leading: Icon(
                              Icons.language,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => SimpleDialog(
                                      title: Text(
                                        context.tr('settings.select_language'),
                                      ),
                                      children: [
                                        SimpleDialogOption(
                                          onPressed: () {
                                            const locale = Locale('en');
                                            context
                                                .read<LocaleCubit>()
                                                .setLocale(locale);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            context.tr('settings.english'),
                                          ),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            const locale = Locale('it');
                                            context
                                                .read<LocaleCubit>()
                                                .setLocale(locale);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            context.tr('settings.italian'),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
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
                  FutureBuilder<String>(
                    future: sl<GetAppVersion>()(),
                    builder: (context, snapshot) {
                      return ListTile(
                        title: Text(context.tr('settings.version')),
                        subtitle: Text(snapshot.data ?? '...'),
                        leading: const Icon(Icons.code),
                      );
                    },
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
