import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static final _fullDateFormatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  static final _shortDateFormatter = DateFormat('d MMM yyyy', 'id_ID');
  static final _monthYearFormatter = DateFormat('MMMM yyyy', 'id_ID');
  static final _dayMonthFormatter = DateFormat('d MMM', 'id_ID');
  static final _timeFormatter = DateFormat('HH:mm', 'id_ID');

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final diff = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: diff)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final diff = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: diff)));
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Check if same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Check if this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final start = startOfWeek(now);
    final end = endOfWeek(now);
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end.add(const Duration(seconds: 1)));
  }

  /// Check if this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Format full date
  /// Example: Senin, 25 Desember 2025
  static String formatFull(DateTime date) {
    return _fullDateFormatter.format(date);
  }

  /// Format short date
  /// Example: 25 Des 2025
  static String formatShort(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  /// Format month year
  /// Example: Desember 2025
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  /// Format day month
  /// Example: 25 Des
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormatter.format(date);
  }

  /// Format time
  /// Example: 14:30
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Format relative date
  /// Example: Today, Yesterday, 25 Des
  static String formatRelative(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isThisWeek(date)) {
      return DateFormat('EEEE', 'id_ID').format(date);
    } else {
      return formatShort(date);
    }
  }

  /// Get date range for period
  static (DateTime, DateTime) getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'today':
        return (startOfDay(now), endOfDay(now));
      case 'week':
        return (startOfWeek(now), endOfWeek(now));
      case 'month':
        return (startOfMonth(now), endOfMonth(now));
      case 'year':
        return (startOfYear(now), endOfYear(now));
      default:
        return (startOfMonth(now), endOfMonth(now));
    }
  }
}
