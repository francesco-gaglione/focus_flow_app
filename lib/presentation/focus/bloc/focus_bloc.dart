import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/fetch_orphan_tasks.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_event.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_state.dart';
import 'package:logger/logger.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final Logger logger = Logger();
  final GetCategoriesAndTasks _getCategoriesAndTasks;
  final FetchOrphanTasks _fetchOrphanTasks;

  FocusBloc({
    required GetCategoriesAndTasks getCategoriesAndTask,
    required FetchOrphanTasks fetchOrphanTasks,
  }) : _getCategoriesAndTasks = getCategoriesAndTask,
       _fetchOrphanTasks = fetchOrphanTasks,
       super(const FocusState()) {
    on<InitState>(_onInitState);
    on<CategorySelected>(_onCategorySelected);
    on<TaskSelected>(_onTaskSelected);
  }

  Future<void> _onInitState(InitState event, Emitter<FocusState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _getCategoriesAndTasks.execute();
      if (result.success && result.categoriesWithTasks != null) {
        final categories =
            result.categoriesWithTasks!
                .map(
                  (cat) => CategoryWithTasks(
                    category: cat.category,
                    tasks: cat.tasks,
                  ),
                )
                .toList();

        final tasksResult = await _fetchOrphanTasks.execute();
        emit(
          FocusState(
            categories: categories,
            orphanTasks: tasksResult.orphanTasks ?? [],
            isLoading: false,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: result.error ?? 'Unknown error',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<FocusState> emit,
  ) async {
    logger.d('Category selected: ${event.category?.name}');
    emit(state.copyWith(selectedCategory: event.category));
  }

  Future<void> _onTaskSelected(
    TaskSelected event,
    Emitter<FocusState> emit,
  ) async {
    logger.d('Task selected: ${event.task?.name}');
    emit(state.copyWith(selectedTask: event.task));
  }
}
