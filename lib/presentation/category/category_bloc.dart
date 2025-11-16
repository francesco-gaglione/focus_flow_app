import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_categories_and_tasks.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';

// Events
abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class CreateCategoryEvent extends CategoryEvent {
  final String name;
  final String? color;
  final String? description;

  CreateCategoryEvent({required this.name, this.color, this.description});
}

class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final String? name;
  final String? color;
  final String? description;

  UpdateCategoryEvent({
    required this.id,
    this.name,
    this.color,
    this.description,
  });
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  DeleteCategoryEvent({required this.id});
}

// State
class CategoryState {
  final List<CategoryWithTasksModel> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<CategoryWithTasksModel>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryWithTasksModel {
  final Category category;
  final List<Task> tasks;

  CategoryWithTasksModel({required this.category, required this.tasks});
}

// Bloc
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesAndTasks _getCategoriesAndTasks;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  CategoryBloc({
    required GetCategoriesAndTasks getCategoriesAndTasks,
    required CreateCategory createCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  }) : _getCategoriesAndTasks = getCategoriesAndTasks,
       _createCategory = createCategory,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory,
       super(const CategoryState(isLoading: true)) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
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
