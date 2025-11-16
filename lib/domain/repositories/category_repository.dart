import '../entities/category.dart';
import '../entities/task.dart';

abstract class CategoryRepository {
  /// Get all categories with their tasks
  Future<List<Category>> getAllCategories();

  /// Get a category by ID
  Future<Category?> getCategoryById(String id);

  /// Get tasks for a specific category
  Future<List<Task>> getTasksByCategoryId(String categoryId);

  /// Create a new category
  Future<Category> createCategory({
    required String name,
    required String color,
    String? description,
  });

  /// Update an existing category
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? color,
    String? description,
  });

  /// Delete a category by ID
  Future<bool> deleteCategory(String id);

  /// Check if a category exists by name
  Future<bool> categoryExistsByName(String name);

  /// Check if a category exists by ID
  Future<bool> categoryExists(String id);
}
