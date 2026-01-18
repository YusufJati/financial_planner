import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/category_repository.dart';
import '../datasources/local/database_service.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseService _db;

  CategoryRepositoryImpl(this._db);

  @override
  Future<List<Category>> getAllCategories() async {
    final box = _db.categoryBox;
    final models = box.values.toList();
    models.sort((a, b) => a.order.compareTo(b.order));
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final box = _db.categoryBox;
    final models = box.values
        .where((c) => c.typeIndex == type.index)
        .toList();
    models.sort((a, b) => a.order.compareTo(b.order));
    return models.map(_toEntity).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final model = _db.categoryBox.get(id);
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<void> createCategory(Category category) async {
    final model = _toModel(category);
    await _db.categoryBox.put(model.id, model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = _toModel(category);
    await _db.categoryBox.put(model.id, model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _db.categoryBox.delete(id);
  }

  Category _toEntity(CategoryModel model) {
    return Category(
      id: model.id,
      name: model.name,
      type: CategoryType.values[model.typeIndex],
      icon: model.icon,
      color: model.color,
      parentId: model.parentId,
      isDefault: model.isDefault,
      order: model.order,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  CategoryModel _toModel(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      typeIndex: entity.type.index,
      icon: entity.icon,
      color: entity.color,
      parentId: entity.parentId,
      isDefault: entity.isDefault,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
