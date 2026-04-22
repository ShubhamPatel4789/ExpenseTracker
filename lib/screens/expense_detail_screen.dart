import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final color = Color(kCategoryColors[expense.category] ?? 0xFF6C63FF);
    final icon = kCategoryIcons[expense.category] ?? '💰';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(expense: expense)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Hero amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                        child:
                            Text(icon, style: const TextStyle(fontSize: 36))),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Formatters.currency(expense.amount),
                    style: TextStyle(
                        color: color,
                        fontSize: 36,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    expense.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(expense.category,
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Details card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_month_rounded,
                    label: 'Date',
                    value: Formatters.date(expense.date),
                  ),
                  const Divider(height: 1, color: AppTheme.divider),
                  _DetailRow(
                    icon: Icons.payment_rounded,
                    label: 'Payment Method',
                    value:
                        '${kPaymentIcons[expense.paymentMethod] ?? ''} ${expense.paymentMethod}',
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const Divider(height: 1, color: AppTheme.divider),
                    _DetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Note',
                      value: expense.note!,
                    ),
                  ],
                  if (expense.isRecurring) ...[
                    const Divider(height: 1, color: AppTheme.divider),
                    _DetailRow(
                      icon: Icons.repeat_rounded,
                      label: 'Recurring',
                      value: expense.recurringFrequency ?? 'Yes',
                      valueColor: AppTheme.primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ID card for reference
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fingerprint_rounded,
                      color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text('ID: ${expense.id.substring(0, 8)}...',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Expense',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpenseProvider>().deleteExpense(expense.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close detail screen
            },
            child:
                const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
