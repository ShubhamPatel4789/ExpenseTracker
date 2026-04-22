import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      locale: 'en_IN',
    );
    return formatter.format(amount);
  }

  static String shortCurrency(double amount, {String symbol = '₹'}) {
    if (amount >= 10000000) return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String shortDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('dd MMM').format(date);
  }

  static String percent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String monthName(int month) {
    return DateFormat('MMM').format(DateTime(2024, month));
  }
}
