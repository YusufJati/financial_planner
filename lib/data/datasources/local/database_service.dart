import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/account_model.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../models/goal_model.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/diary_entry_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _uuid = const Uuid();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(RecurringTransactionModelAdapter());
    Hive.registerAdapter(DiaryEntryModelAdapter());

    // Open boxes
    await Hive.openBox<AccountModel>(DbConstants.accountBox);
    await Hive.openBox<CategoryModel>(DbConstants.categoryBox);
    await Hive.openBox<TransactionModel>(DbConstants.transactionBox);
    await Hive.openBox<BudgetModel>(DbConstants.budgetBox);
    await Hive.openBox<GoalModel>(DbConstants.goalBox);
    await Hive.openBox<RecurringTransactionModel>(DbConstants.recurringBox);
    await Hive.openBox<DiaryEntryModel>(DbConstants.diaryBox);
    await Hive.openBox(DbConstants.settingsBox);

    // Seed default data
    await _seedDefaultData();

    _isInitialized = true;
  }

  String generateId() => _uuid.v4();

  // Boxes getters
  Box<AccountModel> get accountBox =>
      Hive.box<AccountModel>(DbConstants.accountBox);
  Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(DbConstants.categoryBox);
  Box<TransactionModel> get transactionBox =>
      Hive.box<TransactionModel>(DbConstants.transactionBox);
  Box<BudgetModel> get budgetBox =>
      Hive.box<BudgetModel>(DbConstants.budgetBox);
  Box<GoalModel> get goalBox => Hive.box<GoalModel>(DbConstants.goalBox);
  Box<RecurringTransactionModel> get recurringBox =>
      Hive.box<RecurringTransactionModel>(DbConstants.recurringBox);
  Box<DiaryEntryModel> get diaryBox =>
      Hive.box<DiaryEntryModel>(DbConstants.diaryBox);
  Box get settingsBox => Hive.box(DbConstants.settingsBox);

  Future<void> _seedDefaultData() async {
    await _seedDefaultCategories();
    await _seedDefaultAccount();
  }

  Future<void> _seedDefaultCategories() async {
    final box = categoryBox;
    if (box.isNotEmpty) return;

    final now = DateTime.now();

    // Default expense categories
    final expenseCategories = [
      _createCategory('Makanan & Minuman', 0, 'utensils', '#F97316', 0, now),
      _createCategory('Transportasi', 0, 'car', '#3B82F6', 1, now),
      _createCategory('Belanja', 0, 'shopping-bag', '#EC4899', 2, now),
      _createCategory('Tagihan & Utilitas', 0, 'file-text', '#8B5CF6', 3, now),
      _createCategory('Kesehatan', 0, 'heart-pulse', '#EF4444', 4, now),
      _createCategory('Hiburan', 0, 'gamepad-2', '#10B981', 5, now),
      _createCategory('Pendidikan', 0, 'graduation-cap', '#6366F1', 6, now),
      _createCategory('Lainnya', 0, 'more-horizontal', '#6B7280', 7, now),
    ];

    // Default income categories
    final incomeCategories = [
      _createCategory('Gaji', 1, 'briefcase', '#10B981', 0, now),
      _createCategory('Bonus', 1, 'gift', '#F59E0B', 1, now),
      _createCategory('Investasi', 1, 'trending-up', '#3B82F6', 2, now),
      _createCategory('Hadiah', 1, 'heart', '#EC4899', 3, now),
      _createCategory('Lainnya', 1, 'more-horizontal', '#6B7280', 4, now),
    ];

    // Transfer category (system)
    final transferCategory =
        _createCategory('Transfer', 0, 'arrow-left-right', '#8B5CF6', 99, now);

    for (final category in [
      ...expenseCategories,
      ...incomeCategories,
      transferCategory
    ]) {
      await box.put(category.id, category);
    }
  }

  CategoryModel _createCategory(
    String name,
    int typeIndex,
    String icon,
    String color,
    int order,
    DateTime now,
  ) {
    return CategoryModel(
      id: generateId(),
      name: name,
      typeIndex: typeIndex,
      icon: icon,
      color: color,
      isDefault: true,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _seedDefaultAccount() async {
    final box = accountBox;
    if (box.isNotEmpty) return;

    final now = DateTime.now();
    final defaultAccount = AccountModel(
      id: generateId(),
      name: 'Cash',
      typeIndex: 0, // AccountType.cash
      initialBalance: 0,
      icon: 'wallet',
      color: '#10B981',
      isActive: true,
      order: 0,
      createdAt: now,
      updatedAt: now,
    );

    await box.put(defaultAccount.id, defaultAccount);
  }

  Future<void> clearAll() async {
    await transactionBox.clear();
    await budgetBox.clear();
    await goalBox.clear();
    await recurringBox.clear();
    await accountBox.clear();
    await categoryBox.clear();
    await diaryBox.clear();
    // Don't clear settings to preserve user preferences

    // Reseed default data
    await _seedDefaultData();
  }

  // Settings methods
  T? getSetting<T>(String key) {
    return settingsBox.get(key) as T?;
  }

  Future<void> saveSetting<T>(String key, T value) async {
    await settingsBox.put(key, value);
  }
}
