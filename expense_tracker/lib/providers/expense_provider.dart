import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../utils/database_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  Budget? _currentBudget;
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime _selectedMonth = DateTime.now();

  List<Expense> get expenses => _filteredExpenses;
  List<Expense> get allExpenses => _expenses;
  Budget? get currentBudget => _currentBudget;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;
  String get searchQuery => _searchQuery;

  double get monthlyTotal {
    return _expenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get yearlyTotal {
    return _expenses
        .where((e) => e.date.year == _selectedMonth.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get monthlyBudgetPercent {
    if (_currentBudget == null || _currentBudget!.monthlyLimit <= 0)
      return 0.0;
    return monthlyTotal / _currentBudget!.monthlyLimit;
  }

  double get yearlyBudgetPercent {
    if (_currentBudget == null || _currentBudget!.yearlyLimit <= 0) return 0.0;
    return yearlyTotal / _currentBudget!.yearlyLimit;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _expenses = await DatabaseHelper.instance.getAllExpenses();
    _currentBudget = await DatabaseHelper.instance
        .getBudgetForYear(_selectedMonth.year);
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.insertExpense(expense);
    _expenses.insert(0, expense);
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) _expenses[idx] = expense;
    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    _applyFilters();
    notifyListeners();
  }

  Future<void> saveBudget(Budget budget) async {
    await DatabaseHelper.instance.upsertBudget(budget);
    _currentBudget = budget;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    _applyFilters();
    notifyListeners();
    // Reload budget for possibly new year
    DatabaseHelper.instance.getBudgetForYear(month.year).then((b) {
      _currentBudget = b;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = _expenses.where((e) =>
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          (e.note?.toLowerCase().contains(q) ?? false));
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((e) => e.category == _selectedCategory);
    }

    if (_selectedPaymentMethod != null) {
      filtered =
          filtered.where((e) => e.paymentMethod == _selectedPaymentMethod);
    }

    _filteredExpenses = filtered.toList();
  }

  Map<String, double> getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final e in _filteredExpenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Map<String, double> getPaymentMethodTotals() {
    final Map<String, double> totals = {};
    for (final e in _filteredExpenses) {
      totals[e.paymentMethod] = (totals[e.paymentMethod] ?? 0) + e.amount;
    }
    return totals;
  }

  List<Expense> getRecentExpenses({int limit = 5}) {
    return _expenses.take(limit).toList();
  }

  double getAverageDailySpend() {
    if (_filteredExpenses.isEmpty) return 0;
    final days = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return monthlyTotal / days;
  }

  String get topCategory {
    final totals = getCategoryTotals();
    if (totals.isEmpty) return 'N/A';
    return totals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
