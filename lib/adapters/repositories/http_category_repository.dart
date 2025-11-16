import 'package:dio/dio.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/category_repository.dart';
import '../dtos/category_dtos.dart';

class HttpCategoryRepository implements CategoryRepository {
  final Dio _dio;
  final String baseUrl;

  HttpCategoryRepository({
    required Dio dio,
    this.baseUrl = 'http://localhost:3000',
  }) : _dio = dio;

  @override
  Future<List<Category>> getAllCategories() async {
    final response = await _dio.get('$baseUrl/api/categories');
    final dto = GetCategoriesResponseDto.fromJson(response.data);
    return dto.categories
        .map(
          (cat) => Category(
            id: cat.id,
            name: cat.name,
            color: cat.color,
            description: cat.description,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/api/categories/$id');
      final cat = CategoryDto.fromJson(response.data);
      return Category(
        id: cat.id,
        name: cat.name,
        color: cat.color,
        description: cat.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Task>> getTasksByCategoryId(String categoryId) async {
    final response = await _dio.get('$baseUrl/api/categories');
    final dto = GetCategoriesResponseDto.fromJson(response.data);
    final category = dto.categories.firstWhere((cat) => cat.id == categoryId);
    return category.tasks
        .map(
          (task) => Task(
            id: task.id,
            name: task.name,
            description: task.description,
            categoryId: task.categoryId,
            scheduledDate: task.scheduledDate,
            completedAt: task.completedAt,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  @override
  Future<Category> createCategory({
    required String name,
    required String color,
    String? description,
  }) async {
    final dto = CreateCategoryDto(
      name: name,
      color: color,
      description: description,
    );
    await _dio.post('$baseUrl/api/categories', data: dto.toJson());
    // Return created category (assuming API returns it or generate ID)
    return Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? color,
    String? description,
  }) async {
    final dto = UpdateCategoryDto(
      name: name,
      color: color,
      description: description,
    );
    final response = await _dio.put(
      '$baseUrl/api/categories/$id',
      data: dto.toJson(),
    );
    final updated = UpdateCategoryResponseDto.fromJson(response.data);
    return Category(
      id: updated.updatedCategory.id,
      name: updated.updatedCategory.name,
      color: updated.updatedCategory.color,
      description: updated.updatedCategory.description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteCategory(String id) async {
    try {
      await _dio.delete('$baseUrl/api/categories/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> categoryExistsByName(String name) async {
    final categories = await getAllCategories();
    return categories.any(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Future<bool> categoryExists(String id) async {
    final category = await getCategoryById(id);
    return category != null;
  }
}
