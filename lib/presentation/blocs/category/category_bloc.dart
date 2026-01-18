import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final String name;
  final CategoryType type;
  final String icon;
  final String color;

  const CreateCategory({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [name, type, icon, color];
}

class UpdateCategory extends CategoryEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

// State
class CategoryState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;

  const CategoryState({
    this.isLoading = false,
    this.error,
    this.expenseCategories = const [],
    this.incomeCategories = const [],
  });

  CategoryState copyWith({
    bool? isLoading,
    String? error,
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, error, expenseCategories, incomeCategories];
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;
  final DatabaseService _databaseService;

  CategoryBloc({
    required CategoryRepository categoryRepository,
    required DatabaseService databaseService,
  })  : _categoryRepository = categoryRepository,
        _databaseService = databaseService,
        super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await Future.wait([
        _categoryRepository.getCategoriesByType(CategoryType.expense),
        _categoryRepository.getCategoriesByType(CategoryType.income),
      ]);

      emit(state.copyWith(
        isLoading: false,
        expenseCategories: results[0],
        incomeCategories: results[1],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final category = Category(
        id: _databaseService.generateId(),
        name: event.name,
        type: event.type,
        icon: event.icon,
        color: event.color,
        isDefault: false,
        order: 99,
        createdAt: now,
        updatedAt: now,
      );

      await _categoryRepository.createCategory(category);
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _categoryRepository.updateCategory(event.category.copyWith(
        updatedAt: DateTime.now(),
      ));
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _categoryRepository.deleteCategory(event.id);
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
