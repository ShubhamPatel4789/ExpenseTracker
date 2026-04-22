import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/budget_ring.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _monthlyCtrl = TextEditingController();
  final _yearlyCtrl = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _yearlyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _editing = !_editing),
            child: Text(
              _editing ? 'Cancel' : 'Edit',
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          final budget = provider.currentBudget;

          if (!_editing && budget == null) {
            return _buildNoBudget();
          }

          if (_editing) {
            _monthlyCtrl.text = budget?.monthlyLimit.toStringAsFixed(0) ?? '';
            _yearlyCtrl.text = budget?.yearlyLimit.toStringAsFixed(0) ?? '';
            return _buildEditForm(context, provider, budget);
          }

          return _buildBudgetView(provider, budget!);
        },
      ),
    );
  }

  Widget _buildNoBudget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Set Your Budget',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Set monthly and yearly spending targets to stay on track with your finances.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Set Budget Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(
      BuildContext context, ExpenseProvider provider, Budget? existing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Set Spending Limits',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'For ${DateTime.now().year}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _BudgetInputField(
            controller: _monthlyCtrl,
            label: 'Monthly Budget',
            hint: 'e.g. 30000',
            icon: Icons.calendar_month_rounded,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          _BudgetInputField(
            controller: _yearlyCtrl,
            label: 'Yearly Budget',
            hint: 'e.g. 360000',
            icon: Icons.calendar_today_rounded,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 Tip: Set your yearly budget to roughly 12× your monthly limit for consistency.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _saveBudget(context, provider),
              child: const Text('Save Budget',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetView(ExpenseProvider provider, Budget budget) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Budget rings
        Row(
          children: [
            Expanded(
              child: BudgetRing(
                label: 'Monthly',
                spent: provider.monthlyTotal,
                limit: budget.monthlyLimit,
                percent: provider.monthlyBudgetPercent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BudgetRing(
                label: 'Yearly',
                spent: provider.yearlyTotal,
                limit: budget.yearlyLimit,
                percent: provider.yearlyBudgetPercent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Status banners
        if (provider.monthlyBudgetPercent > 1.0)
          _StatusBanner(
            message:
                'Monthly budget exceeded by ${Formatters.currency(provider.monthlyTotal - budget.monthlyLimit)}',
            color: AppTheme.error,
            icon: '🚨',
          ),
        if (provider.monthlyBudgetPercent > 0.8 &&
            provider.monthlyBudgetPercent <= 1.0)
          _StatusBanner(
            message:
                'Warning: ${Formatters.percent(1 - provider.monthlyBudgetPercent)} monthly budget remaining',
            color: AppTheme.warning,
            icon: '⚠️',
          ),
        if (provider.yearlyBudgetPercent > 1.0)
          _StatusBanner(
            message:
                'Yearly budget exceeded by ${Formatters.currency(provider.yearlyTotal - budget.yearlyLimit)}',
            color: AppTheme.error,
            icon: '🚨',
          ),
        const SizedBox(height: 16),
        // Budget details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              _BudgetDetailRow(
                label: 'Monthly Limit',
                value: Formatters.currency(budget.monthlyLimit),
                color: AppTheme.primary,
              ),
              const Divider(color: AppTheme.divider, height: 20),
              _BudgetDetailRow(
                label: 'Spent This Month',
                value: Formatters.currency(provider.monthlyTotal),
                color: provider.monthlyBudgetPercent > 1.0
                    ? AppTheme.error
                    : AppTheme.success,
              ),
              const Divider(color: AppTheme.divider, height: 20),
              _BudgetDetailRow(
                label: 'Monthly Remaining',
                value: Formatters.currency(
                    (budget.monthlyLimit - provider.monthlyTotal).abs()),
                color: provider.monthlyBudgetPercent > 1.0
                    ? AppTheme.error
                    : AppTheme.success,
                prefix: provider.monthlyBudgetPercent > 1.0 ? '-' : '',
              ),
              const Divider(color: AppTheme.divider, height: 20),
              _BudgetDetailRow(
                label: 'Yearly Limit',
                value: Formatters.currency(budget.yearlyLimit),
                color: AppTheme.accent,
              ),
              const Divider(color: AppTheme.divider, height: 20),
              _BudgetDetailRow(
                label: 'Spent This Year',
                value: Formatters.currency(provider.yearlyTotal),
                color: provider.yearlyBudgetPercent > 1.0
                    ? AppTheme.error
                    : AppTheme.success,
              ),
              const Divider(color: AppTheme.divider, height: 20),
              _BudgetDetailRow(
                label: 'Yearly Remaining',
                value: Formatters.currency(
                    (budget.yearlyLimit - provider.yearlyTotal).abs()),
                color: provider.yearlyBudgetPercent > 1.0
                    ? AppTheme.error
                    : AppTheme.success,
                prefix: provider.yearlyBudgetPercent > 1.0 ? '-' : '',
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _saveBudget(BuildContext context, ExpenseProvider provider) {
    final monthly =
        double.tryParse(_monthlyCtrl.text.replaceAll(',', '')) ?? 0;
    final yearly = double.tryParse(_yearlyCtrl.text.replaceAll(',', '')) ?? 0;

    if (monthly <= 0 || yearly <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter valid budget amounts'),
            backgroundColor: AppTheme.error),
      );
      return;
    }

    provider.saveBudget(Budget(
      monthlyLimit: monthly,
      yearlyLimit: yearly,
      year: DateTime.now().year,
    ));

    setState(() => _editing = false);
  }
}

class _BudgetInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;

  const _BudgetInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w600),
            hintText: hint,
            prefixIcon: Icon(icon, color: color, size: 20),
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final Color color;
  final String icon;

  const _StatusBanner(
      {required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _BudgetDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String prefix;

  const _BudgetDetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        Text('$prefix$value',
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
