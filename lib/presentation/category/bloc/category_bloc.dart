import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/create_category.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/delete_category.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/get_categories_and_tasks.dart';
import 'package:focus_flow_app/domain/usecases/categories_usecases/update_category.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/create_task.dart';
import 'package:focus_flow_app/domain/usecases/tasks_usecases/fetch_orphan_tasks.dart';
import 'package:focus_flow_app/presentation/category/bloc/category_event.dart';
import 'package:focus_flow_app/presentation/category/bloc/category_state.dart';

// Bloc
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesAndTasks _getCategoriesAndTasks;
  final FetchOrphanTasks _fetchOrphanTasks;
  final CreateCategory _createCategory;
  final CreateTask _createTask;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  CategoryBloc({
    required GetCategoriesAndTasks getCategoriesAndTasks,
    required FetchOrphanTasks fetchOrphanTasks,
    required CreateCategory createCategory,
    required CreateTask createTask,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  }) : _getCategoriesAndTasks = getCategoriesAndTasks,
       _fetchOrphanTasks = fetchOrphanTasks,
       _createCategory = createCategory,
       _createTask = createTask,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory,
       super(const CategoryState(isLoading: true)) {
    on<InitState>(_onInitState);
    on<LoadCategories>(_onLoadCategories);
    on<LoadOrphanTasks>(_onLoadOrphanTasks);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<CreateOrphanTaskEvent>(_onCreateOrphanTask);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onInitState(
    InitState event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _getCategoriesAndTasks.execute();
      if (result.success && result.categoriesWithTasks != null) {
        final categories =
            result.categoriesWithTasks!
                .map(
                  (cat) => CategoryWithTasksModel(
                    category: cat.category,
                    tasks: cat.tasks,
                  ),
                )
                .toList();

        final tasksResult = await _fetchOrphanTasks.execute();
        emit(
          CategoryState(
            categories: categories,
            tasks: tasksResult.orphanTasks ?? [],
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

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _getCategoriesAndTasks.execute();
      if (result.success && result.categoriesWithTasks != null) {
        final categories =
            result.categoriesWithTasks!
                .map(
                  (cat) => CategoryWithTasksModel(
                    category: cat.category,
                    tasks: cat.tasks,
                  ),
                )
                .toList();
        emit(
          CategoryState(
            categories: categories,
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

  Future<void> _onLoadOrphanTasks(
    LoadOrphanTasks event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _fetchOrphanTasks.execute();
      if (result.success && result.orphanTasks != null) {
        emit(
          CategoryState(
            tasks: result.orphanTasks ?? [],
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

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final result = await _createCategory.execute(
        name: event.name,
        color: event.color,
        description: event.description,
      );
      if (result.success) {
        add(LoadCategories());
      } else {
        emit(
          state.copyWith(
            errorMessage: result.error ?? 'Failed to create category',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateOrphanTask(
    CreateOrphanTaskEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final result = await _createTask.execute(
        name: event.title,
        description: event.description,
      );
      if (result.success) {
        add(LoadOrphanTasks());
      } else {
        emit(
          state.copyWith(
            errorMessage: result.error ?? 'Failed to create orphan task',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final result = await _updateCategory.execute(
        id: event.id,
        name: event.name,
        color: event.color,
        description: event.description,
      );
      if (result.success) {
        add(LoadCategories());
      } else {
        emit(
          state.copyWith(
            errorMessage: result.error ?? 'Failed to update category',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final result = await _deleteCategory.execute(id: event.id);
      if (result.success) {
        add(LoadCategories());
      } else {
        emit(
          state.copyWith(
            errorMessage: result.error ?? 'Failed to delete category',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
