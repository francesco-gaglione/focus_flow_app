import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../app/locale_cubit.dart';
import '../app/theme_cubit.dart';
import '../../domain/usecases/get_app_version.dart';
import '../../core/di/service_locator.dart';
import 'cubit/account_cubit.dart';
import 'cubit/account_state.dart';
import '../auth/cubit/auth_cubit.dart';

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
          _buildAccountSection(context),
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

  Widget _buildAccountSection(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AccountCubit>()..loadUserInfo(),
      child: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, state) {
          if (state is AccountSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AccountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          String? currentUsername;
          bool isAdmin = false;
          if (state is AccountLoaded) {
            currentUsername = state.userInfo.username;
            isAdmin = state.userInfo.role == 'Admin';
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Account${currentUsername != null ? ' ($currentUsername)' : ''}',
                        // TODO: Add to translations context.tr('settings.account'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state is AccountLoading && currentUsername == null)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ListTile(
                      title: const Text('Change Username'), // TODO: Translate
                      leading: const Icon(Icons.person),
                      onTap:
                          state is AccountLoading
                              ? null
                              : () => _showChangeUsernameDialog(
                                context,
                                currentUsername,
                              ),
                    ),
                    ListTile(
                      title: const Text('Change Password'), // TODO: Translate
                      leading: const Icon(Icons.lock),
                      onTap:
                          state is AccountLoading
                              ? null
                              : () => _showChangePasswordDialog(context),
                    ),
                    if (isAdmin)
                      ListTile(
                        title: const Text('Create User'), // TODO: Translate
                        leading: const Icon(Icons.person_add),
                        onTap:
                            state is AccountLoading
                                ? null
                                : () => _showCreateUserDialog(context),
                      ),
                    const Divider(),
                    ListTile(
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ), // TODO: Translate
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        context.read<AuthCubit>().logout();
                        // Router will handle redirect
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateUserDialog(BuildContext context) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<AccountCubit>(),
            child: AlertDialog(
              title: const Text('Create User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AccountCubit>().createUser(
                      usernameController.text,
                      passwordController.text,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showChangeUsernameDialog(
    BuildContext context,
    String? currentUsername,
  ) async {
    final controller = TextEditingController(text: currentUsername);
    await showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<AccountCubit>(),
            child: AlertDialog(
              title: const Text('Change Username'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'New Username'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AccountCubit>().changeUsername(
                      controller.text,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<AccountCubit>(),
            child: AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPassController,
                    decoration: const InputDecoration(
                      labelText: 'Old Password',
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: newPassController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AccountCubit>().changePassword(
                      oldPassController.text,
                      newPassController.text,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
    );
  }
}
