import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/domain/entities/theme_settings.dart';
import 'package:focus_flow_app/presentation/app/theme_cubit.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_bloc.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_event.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_state.dart';
import 'package:focus_flow_app/presentation/widgets/focus/category_task_selector.dart';
import 'package:focus_flow_app/presentation/widgets/focus/focus_level_selector.dart';
import 'package:focus_flow_app/presentation/widgets/focus/focus_notes.dart';
import 'package:focus_flow_app/presentation/widgets/focus/focus_timeline.dart';
import 'package:focus_flow_app/presentation/widgets/focus/focus_timer.dart';

class FocusView extends StatelessWidget {
  const FocusView({Key? key}) : super(key: key);

  // Breakpoint for desktop layout
  static const double desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus'), centerTitle: false),
      body: BlocConsumer<FocusBloc, FocusState>(
        listener: (context, state) {
          if (state.selectedCategory != null) {
            try {
              int colorInt = int.parse(
                state.selectedCategory!.color.replaceFirst('#', '0xFF'),
              );
              context.read<ThemeCubit>().updateAccentColor(colorInt);
            } catch (e) {
              // Handle error
            }
          } else {
            context.read<ThemeCubit>().updateAccentColor(
              ThemeSettings.defaultAccentColor,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= desktopBreakpoint;

              if (isDesktop) {
                return _buildDesktopLayout(context, state);
              } else {
                return _buildMobileLayout(context, state);
              }
            },
          );
        },
      ),
    );
  }

  /// Desktop layout with split view
  Widget _buildDesktopLayout(BuildContext context, FocusState state) {
    return Row(
      children: [
        // Left side - Timer, Focus Level, Notes
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timer Widget
                  const FocusTimerWidget(),
                  const SizedBox(height: 32),

                  // Focus Level Selector
                  const FocusLevelSelector(),
                  const SizedBox(height: 32),

                  // Notes
                  const FocusNotesWidget(),
                ],
              ),
            ),
          ),
        ),

        // Right side - Category/Task Selector and Timeline
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategoryTaskSelector(
                  categories: state.categories,
                  orphanTasks: state.orphanTasks,
                  onCategoryChanged:
                      (category) => context.read<FocusBloc>().add(
                        CategorySelected(category: category),
                      ),
                  onTaskChanged:
                      (task) => context.read<FocusBloc>().add(
                        TaskSelected(task: task),
                      ),
                ),
                const SizedBox(height: 32),
                const FocusTimelineWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile layout with vertical scroll
  Widget _buildMobileLayout(BuildContext context, FocusState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timer Widget
          const FocusTimerWidget(),
          const SizedBox(height: 24),

          // Category and Task Selector - Pass data from state
          CategoryTaskSelector(
            categories: state.categories,
            orphanTasks: state.orphanTasks,
          ),
          const SizedBox(height: 24),

          // Focus Level Selector
          const FocusLevelSelector(),
          const SizedBox(height: 24),

          // Notes
          const FocusNotesWidget(),
          const SizedBox(height: 24),

          // Timeline
          const FocusTimelineWidget(),
        ],
      ),
    );
  }
}
