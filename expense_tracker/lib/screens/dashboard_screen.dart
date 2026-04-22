import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/expense_card.dart';
import '../widgets/budget_ring.dart';
import 'expense_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(provider),
                      const SizedBox(height: 24),
                      _buildBudgetSection(context, provider),
                      const SizedBox(height: 24),
                      _buildCategoryBreakdown(provider),
                      const SizedBox(height: 24),
                      _buildRecentExpenses(context, provider),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ExpenseProvider provider) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: AppTheme.background,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Expenses',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                Formatters.monthYear(provider.selectedMonth),
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              _MonthNavigator(provider: provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ExpenseProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'This Month',
            amount: provider.monthlyTotal,
            icon: Icons.calendar_month_rounded,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'This Year',
            amount: provider.yearlyTotal,
            icon: Icons.calendar_today_rounded,
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection(BuildContext context, ExpenseProvider provider) {
    final budget = provider.currentBudget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budget Status',
                style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/budget'),
              icon: const Icon(Icons.edit_rounded,
                  size: 16, color: AppTheme.primary),
              label: const Text('Set Budget',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (budget == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppTheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No budget set for this year. Tap "Set Budget" to add one.',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
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
      ],
    );
  }

  Widget _buildCategoryBreakdown(ExpenseProvider provider) {
    final totals = provider.getCategoryTotals();
    if (totals.isEmpty) return const SizedBox.shrink();

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(4).toList();
    final total = totals.values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: top.map((entry) {
              final color = Color(kCategoryColors[entry.key] ?? 0xFF6C63FF);
              final pct = total > 0 ? entry.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(kCategoryIcons[entry.key] ?? '💰', style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(entry.key,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                        Text(Formatters.currency(entry.value),
                            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: AppTheme.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpenses(BuildContext context, ExpenseProvider provider) {
    final recent = provider.getRecentExpenses(limit: 5);
    if (recent.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Expenses',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Center(
              child: Column(
                children: [
                  Text('💸', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text('No expenses yet',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 15)),
                  Text('Tap + to add your first expense',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Expenses', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...recent.map((e) => ExpenseCard(
              expense: e,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ExpenseDetailScreen(expense: e))),
            )),
      ],
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final ExpenseProvider provider;
  const _MonthNavigator({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textSecondary),
          onPressed: () {
            final m = provider.selectedMonth;
            provider.setSelectedMonth(DateTime(m.year, m.month - 1));
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          onPressed: () {
            final m = provider.selectedMonth;
            provider.setSelectedMonth(DateTime(m.year, m.month + 1));
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(Formatters.shortCurrency(amount),
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
