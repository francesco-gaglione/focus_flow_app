import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository categoryRepository;

  DeleteCategory({required this.categoryRepository});

  Future<DeleteCategoryResult> execute({required String id}) async {
    try {
      // Check if category exists
      final exists = await categoryRepository.categoryExists(id);
      if (!exists) {
        return DeleteCategoryResult(
          success: false,
          error: 'Category not found',
          errorType: DeleteCategoryErrorType.notFound,
        );
      }

      // Delete category (and its tasks according to the API spec)
      final deleted = await categoryRepository.deleteCategory(id);

      if (!deleted) {
        return DeleteCategoryResult(
          success: false,
          error: 'Failed to delete category',
          errorType: DeleteCategoryErrorType.internal,
        );
      }

      return DeleteCategoryResult(success: true, deletedIds: [id]);
    } catch (e) {
      return DeleteCategoryResult(
        success: false,
        error: e.toString(),
        errorType: DeleteCategoryErrorType.internal,
      );
    }
  }
}

enum DeleteCategoryErrorType { notFound, internal }

class DeleteCategoryResult {
  final bool success;
  final List<String>? deletedIds;
  final String? error;
  final DeleteCategoryErrorType? errorType;

  DeleteCategoryResult({
    required this.success,
    this.deletedIds,
    this.error,
    this.errorType,
  });
}
