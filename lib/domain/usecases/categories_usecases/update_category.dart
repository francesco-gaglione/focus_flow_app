import 'package:focus_flow_app/domain/entities/category.dart';
import 'package:focus_flow_app/domain/repositories/category_repository.dart';

class UpdateCategory {
  final CategoryRepository categoryRepository;

  UpdateCategory({required this.categoryRepository});

  Future<UpdateCategoryResult> execute({
    required String id,
    String? name,
    String? color,
    String? description,
  }) async {
    try {
      // Check if category exists
      final exists = await categoryRepository.categoryExists(id);
      if (!exists) {
        return UpdateCategoryResult(
          success: false,
          error: 'Category not found',
          errorType: UpdateCategoryErrorType.notFound,
        );
      }

      // Validate name if provided
      if (name != null && name.trim().isEmpty) {
        return UpdateCategoryResult(
          success: false,
          error: 'Category name cannot be empty',
          errorType: UpdateCategoryErrorType.validation,
        );
      }

      // Check if new name conflicts with existing category
      if (name != null) {
        final currentCategory = await categoryRepository.getCategoryById(id);
        if (currentCategory != null && currentCategory.name != name) {
          final nameExists = await categoryRepository.categoryExistsByName(
            name,
          );
          if (nameExists) {
            return UpdateCategoryResult(
              success: false,
              error: 'Category with this name already exists',
              errorType: UpdateCategoryErrorType.conflict,
            );
          }
        }
      }

      // Update category
      final updatedCategory = await categoryRepository.updateCategory(
        id: id,
        name: name,
        color: color,
        description: description,
      );

      return UpdateCategoryResult(success: true, category: updatedCategory);
    } catch (e) {
      return UpdateCategoryResult(
        success: false,
        error: e.toString(),
        errorType: UpdateCategoryErrorType.internal,
      );
    }
  }
}

enum UpdateCategoryErrorType { validation, notFound, conflict, internal }

class UpdateCategoryResult {
  final bool success;
  final Category? category;
  final String? error;
  final UpdateCategoryErrorType? errorType;

  UpdateCategoryResult({
    required this.success,
    this.category,
    this.error,
    this.errorType,
  });
}
