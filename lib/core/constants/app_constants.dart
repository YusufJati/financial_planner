// Database box names
class DbConstants {
  DbConstants._();

  static const String accountBox = 'accounts';
  static const String categoryBox = 'categories';
  static const String transactionBox = 'transactions';
  static const String budgetBox = 'budgets';
  static const String goalBox = 'goals';
  static const String recurringBox = 'recurring';
  static const String settingsBox = 'settings';
  static const String diaryBox = 'diaries';
}

// Enums
enum AccountType {
  cash,
  bank,
  eWallet,
  creditCard;

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank';
      case AccountType.eWallet:
        return 'E-Wallet';
      case AccountType.creditCard:
        return 'Credit Card';
    }
  }

  String get icon {
    switch (this) {
      case AccountType.cash:
        return 'wallet';
      case AccountType.bank:
        return 'building-2';
      case AccountType.eWallet:
        return 'smartphone';
      case AccountType.creditCard:
        return 'credit-card';
    }
  }
}

enum TransactionType {
  income,
  expense,
  transfer;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

enum CategoryType {
  expense,
  income;

  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
    }
  }
}

enum RecurringFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.biweekly:
        return 'Bi-weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }
}

// App Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Financial Planner';
  static const String currencySymbol = 'Rp';
  static const String currencyCode = 'IDR';
  static const int decimalDigits = 0;

  static const int pageSize = 50;
  static const int debounceMilliseconds = 300;

  static const double budgetWarningThreshold = 0.8; // 80%
  static const double budgetDangerThreshold = 1.0; // 100%
}
