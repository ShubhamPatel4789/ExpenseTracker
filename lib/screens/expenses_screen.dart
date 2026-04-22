import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  context.read<ExpenseProvider>().setSearchQuery(v),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ExpenseProvider>().setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, _) {
                final expenses = provider.expenses;
                if (expenses.isEmpty) {
                  return _buildEmpty(provider);
                }

                // Group by date
                final grouped = <String, List<Expense>>{};
                for (final e in expenses) {
                  final key = Formatters.shortDate(e.date);
                  grouped.putIfAbsent(key, () => []).add(e);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final date = grouped.keys.elementAt(i);
                    final dayExpenses = grouped.values.elementAt(i);
                    final dayTotal = dayExpenses.fold(0.0, (s, e) => s + e.amount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(date,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5)),
                              Text(Formatters.currency(dayTotal),
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        ...dayExpenses.map((e) => ExpenseCard(
                              expense: e,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ExpenseDetailScreen(expense: e)),
                              ),
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddExpenseScreen(expense: e)),
                              ),
                              onDelete: () => _confirmDelete(context, provider, e),
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ExpenseProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            provider.searchQuery.isNotEmpty
                ? 'No results found'
                : 'No expenses this month',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            provider.searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Start adding your expenses',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(
        selectedCategory: _selectedCategory,
        selectedPaymentMethod: _selectedPaymentMethod,
        onCategoryChanged: (cat) {
          setState(() => _selectedCategory = cat);
          context.read<ExpenseProvider>().setSelectedCategory(cat);
          Navigator.pop(context);
        },
        onPaymentMethodChanged: (method) {
          setState(() => _selectedPaymentMethod = method);
          context.read<ExpenseProvider>().setSelectedPaymentMethod(method);
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _selectedCategory = null;
            _selectedPaymentMethod = null;
          });
          final provider = context.read<ExpenseProvider>();
          provider.setSelectedCategory(null);
          provider.setSelectedPaymentMethod(null);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ExpenseProvider provider, Expense e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Expense',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Delete "${e.title}"?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteExpense(e.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedPaymentMethod;
  final Function(String?) onCategoryChanged;
  final Function(String?) onPaymentMethodChanged;
  final VoidCallback onClear;

  const _FilterSheet({
    this.selectedCategory,
    this.selectedPaymentMethod,
    required this.onCategoryChanged,
    required this.onPaymentMethodChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear All',
                    style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Category',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kCategories
                .map((cat) => FilterChip(
                      label: Text(
                          '${kCategoryIcons[cat] ?? ''} $cat',
                          style: const TextStyle(fontSize: 12)),
                      selected: selectedCategory == cat,
                      onSelected: (_) => onCategoryChanged(
                          selectedCategory == cat ? null : cat),
                      selectedColor: AppTheme.primary.withOpacity(0.3),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Payment Method',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kPaymentMethods
                .map((m) => FilterChip(
                      label: Text('${kPaymentIcons[m] ?? ''} $m',
                          style: const TextStyle(fontSize: 12)),
                      selected: selectedPaymentMethod == m,
                      onSelected: (_) => onPaymentMethodChanged(
                          selectedPaymentMethod == m ? null : m),
                      selectedColor: AppTheme.primary.withOpacity(0.3),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
