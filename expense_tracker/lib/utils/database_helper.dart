import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        isRecurring INTEGER DEFAULT 0,
        recurringFrequency TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        monthlyLimit REAL NOT NULL,
        yearlyLimit REAL NOT NULL,
        year INTEGER NOT NULL
      )
    ''');
  }

  // Expense CRUD
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update('expenses', expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();
    final maps = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByYear(int year) async {
    final db = await database;
    final start = DateTime(year, 1, 1).toIso8601String();
    final end = DateTime(year + 1, 1, 1).toIso8601String();
    final maps = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> searchExpenses(String query) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'title LIKE ? OR category LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  // Budget CRUD
  Future<void> upsertBudget(Budget budget) async {
    final db = await database;
    final existing = await db.query('budgets',
        where: 'year = ?', whereArgs: [budget.year]);
    if (existing.isEmpty) {
      await db.insert('budgets', budget.toMap());
    } else {
      await db.update('budgets', budget.toMap(),
          where: 'year = ?', whereArgs: [budget.year]);
    }
  }

  Future<Budget?> getBudgetForYear(int year) async {
    final db = await database;
    final maps =
        await db.query('budgets', where: 'year = ?', whereArgs: [year]);
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  Future<Map<String, double>> getCategoryTotalsForMonth(
      int year, int month) async {
    final expenses = await getExpensesByMonth(year, month);
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<Map<String, double>> getPaymentMethodTotalsForMonth(
      int year, int month) async {
    final expenses = await getExpensesByMonth(year, month);
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.paymentMethod] =
          (totals[e.paymentMethod] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<List<Map<String, dynamic>>> getDailyTotalsForMonth(
      int year, int month) async {
    final expenses = await getExpensesByMonth(year, month);
    final Map<int, double> dailyMap = {};
    for (final e in expenses) {
      dailyMap[e.date.day] = (dailyMap[e.date.day] ?? 0) + e.amount;
    }
    return dailyMap.entries
        .map((e) => {'day': e.key, 'amount': e.value})
        .toList()
      ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  }

  Future<List<Map<String, dynamic>>> getMonthlyTotalsForYear(int year) async {
    final expenses = await getExpensesByYear(year);
    final Map<int, double> monthlyMap = {};
    for (final e in expenses) {
      monthlyMap[e.date.month] =
          (monthlyMap[e.date.month] ?? 0) + e.amount;
    }
    return monthlyMap.entries
        .map((e) => {'month': e.key, 'amount': e.value})
        .toList()
      ..sort((a, b) => (a['month'] as int).compareTo(b['month'] as int));
  }
}
