import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String paymentMethod;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final String? recurringFrequency;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringFrequency,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringFrequency': recurringFrequency,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      paymentMethod: map['paymentMethod'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      isRecurring: map['isRecurring'] == 1,
      recurringFrequency: map['recurringFrequency'],
    );
  }

  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? note,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }
}

class Budget {
  final String id;
  final double monthlyLimit;
  final double yearlyLimit;
  final int year;

  Budget({
    String? id,
    required this.monthlyLimit,
    required this.yearlyLimit,
    required this.year,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthlyLimit': monthlyLimit,
      'yearlyLimit': yearlyLimit,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      monthlyLimit: (map['monthlyLimit'] as num).toDouble(),
      yearlyLimit: (map['yearlyLimit'] as num).toDouble(),
      year: map['year'],
    );
  }

  Budget copyWith({double? monthlyLimit, double? yearlyLimit, int? year}) {
    return Budget(
      id: id,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      yearlyLimit: yearlyLimit ?? this.yearlyLimit,
      year: year ?? this.year,
    );
  }
}

const List<String> kCategories = [
  'Food & Dining',
  'Transportation',
  'Shopping',
  'Entertainment',
  'Health & Medical',
  'Utilities',
  'Housing',
  'Education',
  'Travel',
  'Personal Care',
  'Gifts & Donations',
  'Subscriptions',
  'Investments',
  'Other',
];

const List<String> kPaymentMethods = [
  'Cash',
  'Credit Card',
  'Debit Card',
  'UPI / Mobile Pay',
  'Bank Transfer',
  'Cryptocurrency',
  'Cheque',
  'Buy Now Pay Later',
  'Other',
];

const Map<String, String> kCategoryIcons = {
  'Food & Dining': '🍽️',
  'Transportation': '🚗',
  'Shopping': '🛍️',
  'Entertainment': '🎬',
  'Health & Medical': '🏥',
  'Utilities': '💡',
  'Housing': '🏠',
  'Education': '📚',
  'Travel': '✈️',
  'Personal Care': '💆',
  'Gifts & Donations': '🎁',
  'Subscriptions': '📱',
  'Investments': '📈',
  'Other': '💰',
};

const Map<String, int> kCategoryColors = {
  'Food & Dining': 0xFFFF6B6B,
  'Transportation': 0xFF4ECDC4,
  'Shopping': 0xFFFFE66D,
  'Entertainment': 0xFFA78BFA,
  'Health & Medical': 0xFF06D6A0,
  'Utilities': 0xFF118AB2,
  'Housing': 0xFFFF9F1C,
  'Education': 0xFF2EC4B6,
  'Travel': 0xFFE9C46A,
  'Personal Care': 0xFFF4A261,
  'Gifts & Donations': 0xFFE76F51,
  'Subscriptions': 0xFF457B9D,
  'Investments': 0xFF2D6A4F,
  'Other': 0xFF6C757D,
};

const Map<String, String> kPaymentIcons = {
  'Cash': '💵',
  'Credit Card': '💳',
  'Debit Card': '🏦',
  'UPI / Mobile Pay': '📲',
  'Bank Transfer': '🔄',
  'Cryptocurrency': '₿',
  'Cheque': '📝',
  'Buy Now Pay Later': '⏰',
  'Other': '💰',
};
