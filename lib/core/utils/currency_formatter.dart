import 'package:intl/intl.dart';
import '../../injection.dart';
import '../../data/datasources/local/database_service.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _numberFormatter = NumberFormat('#,###', 'id_ID');
  static final _decimalFormatter = NumberFormat('#,##0.00', 'en_US');

  static const Map<String, String> _currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'SGD': 'S\$',
    'MYR': 'RM',
  };

  // Exchange rates to IDR (base currency is IDR)
  // Rates as of January 6, 2026
  static const Map<String, double> _exchangeRatesToIDR = {
    'IDR': 1.0,
    'USD': 16750.0, // 1 USD = 16,750 IDR
    'EUR': 17400.0, // 1 EUR = 17,400 IDR
    'GBP': 21100.0, // 1 GBP = 21,100 IDR
    'JPY': 108.0, // 1 JPY = 108 IDR
    'SGD': 12400.0, // 1 SGD = 12,400 IDR
    'MYR': 3750.0, // 1 MYR = 3,750 IDR
  };

  static String _getCurrencyCode() {
    try {
      final db = getIt<DatabaseService>();
      return db.getSetting<String>('currencyCode') ?? 'IDR';
    } catch (_) {
      return 'IDR';
    }
  }

  static String _getSymbol() {
    final currencyCode = _getCurrencyCode();
    return _currencySymbols[currencyCode] ?? 'Rp';
  }

  /// Convert amount from IDR to selected currency
  static double _convertFromIDR(double amountInIDR) {
    final currencyCode = _getCurrencyCode();
    final rate = _exchangeRatesToIDR[currencyCode] ?? 1.0;
    return amountInIDR / rate;
  }

  /// Format amount with currency symbol (converts from IDR to selected currency)
  /// Example: Rp 1.500.000 or $89.55
  static String format(double amountInIDR) {
    final symbol = _getSymbol();
    final currencyCode = _getCurrencyCode();
    final convertedAmount = _convertFromIDR(amountInIDR);

    // Use decimal format for non-IDR currencies
    String formatted;
    if (currencyCode == 'IDR') {
      formatted = _numberFormatter.format(convertedAmount.abs());
    } else {
      formatted = _decimalFormatter.format(convertedAmount.abs());
    }

    if (amountInIDR < 0) {
      return '-$symbol $formatted';
    }
    return '$symbol $formatted';
  }

  /// Format amount with sign
  /// Example: +$89.55 or -$89.55
  static String formatWithSign(double amountInIDR, {bool isExpense = false}) {
    final sign = isExpense ? '-' : '+';
    final symbol = _getSymbol();
    final currencyCode = _getCurrencyCode();
    final convertedAmount = _convertFromIDR(amountInIDR);

    String formatted;
    if (currencyCode == 'IDR') {
      formatted = _numberFormatter.format(convertedAmount.abs());
    } else {
      formatted = _decimalFormatter.format(convertedAmount.abs());
    }
    return '$sign$symbol $formatted';
  }

  /// Format compact for large numbers (converts from IDR)
  /// Example: $89.5K
  static String formatCompact(double amountInIDR) {
    final symbol = _getSymbol();
    final convertedAmount = _convertFromIDR(amountInIDR);

    if (convertedAmount.abs() >= 1000000000) {
      return '$symbol ${(convertedAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (convertedAmount.abs() >= 1000000) {
      return '$symbol ${(convertedAmount / 1000000).toStringAsFixed(1)}M';
    } else if (convertedAmount.abs() >= 1000) {
      return '$symbol ${(convertedAmount / 1000).toStringAsFixed(1)}K';
    }
    return format(amountInIDR);
  }

  /// Format number only without currency (no conversion)
  /// Example: 1.500.000
  static String formatNumber(double amount) {
    return _numberFormatter.format(amount);
  }

  /// Parse formatted string back to double (returns IDR value)
  static double parse(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[^\d,.-]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }
}
