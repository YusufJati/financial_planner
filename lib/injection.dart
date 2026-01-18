import 'package:get_it/get_it.dart';
import 'data/datasources/local/database_service.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/budget_repository_impl.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'data/repositories/diary_repository_impl.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/budget_repository.dart';
import 'domain/repositories/goal_repository.dart';
import 'domain/repositories/recurring_transaction_repository.dart';
import 'domain/repositories/diary_repository.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/blocs/transaction/transaction_bloc.dart';
import 'presentation/blocs/account/account_bloc.dart';
import 'presentation/blocs/budget/budget_bloc.dart';
import 'presentation/blocs/report/report_bloc.dart';
import 'presentation/blocs/category/category_bloc.dart';
import 'presentation/blocs/goal/goal_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/recurring/recurring_bloc.dart';
import 'presentation/blocs/diary/diary_bloc.dart';
import 'data/repositories/recurring_transaction_repository_impl.dart';
import 'data/services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Repositories
  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(getIt<DatabaseService>()),
  );

  // BLoCs
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      accountRepository: getIt<AccountRepository>(),
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      accountRepository: getIt<AccountRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  getIt.registerFactory<AccountBloc>(
    () => AccountBloc(
      accountRepository: getIt<AccountRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  getIt.registerFactory<BudgetBloc>(
    () => BudgetBloc(
      budgetRepository: getIt<BudgetRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  getIt.registerFactory<ReportBloc>(
    () => ReportBloc(
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      categoryRepository: getIt<CategoryRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  getIt.registerFactory<GoalBloc>(
    () => GoalBloc(
      goalRepository: getIt<GoalRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  getIt.registerFactory<DiaryBloc>(
    () => DiaryBloc(
      diaryRepository: getIt<DiaryRepository>(),
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  // SettingsBloc as singleton for global theme management
  getIt.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(
      databaseService: getIt<DatabaseService>(),
      notificationService: getIt<NotificationService>(),
    )..add(LoadSettings()),
  );

  // Recurring Repository
  getIt.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepositoryImpl(getIt<DatabaseService>()),
  );

  // RecurringBloc
  getIt.registerFactory<RecurringBloc>(
    () => RecurringBloc(
      recurringRepository: getIt<RecurringTransactionRepository>(),
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      accountRepository: getIt<AccountRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );
}
