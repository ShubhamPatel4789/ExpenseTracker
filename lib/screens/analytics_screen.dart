import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Payment'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _CategoryTab(provider: provider),
              _PaymentTab(provider: provider),
              _TrendsTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTab extends StatefulWidget {
  final ExpenseProvider provider;
  const _CategoryTab({required this.provider});

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final totals = widget.provider.getCategoryTotals();
    if (totals.isEmpty) return _buildEmpty();

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = totals.values.fold(0.0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              sections: sorted.asMap().entries.map((entry) {
                final i = entry.key;
                final cat = entry.value.key;
                final amount = entry.value.value;
                final isTouched = i == _touchedIndex;
                final color = Color(kCategoryColors[cat] ?? 0xFF6C63FF);

                return PieChartSectionData(
                  color: color,
                  value: amount,
                  title: isTouched
                      ? '${(amount / total * 100).toStringAsFixed(1)}%'
                      : '',
                  radius: isTouched ? 80 : 65,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...sorted.map((entry) {
          final color = Color(kCategoryColors[entry.key] ?? 0xFF6C63FF);
          final pct = entry.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(kCategoryIcons[entry.key] ?? '💰',
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text(Formatters.currency(entry.value),
                              style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                      Text('${(pct * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 60),
      ],
    );
  }
}

class _PaymentTab extends StatelessWidget {
  final ExpenseProvider provider;
  const _PaymentTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totals = provider.getPaymentMethodTotals();
    if (totals.isEmpty) return _buildEmpty();

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = totals.values.fold(0.0, (a, b) => a + b);

    final colors = [
      AppTheme.primary,
      AppTheme.accent,
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF06D6A0),
      const Color(0xFFFF9F1C),
      const Color(0xFFA78BFA),
      const Color(0xFF118AB2),
      const Color(0xFFE76F51),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: sorted.first.value * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      Formatters.shortCurrency(rod.toY),
                      const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx >= sorted.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          kPaymentIcons[sorted[idx].key] ?? '💰',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) => Text(
                      Formatters.shortCurrency(value),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 9),
                    ),
                    reservedSize: 45,
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppTheme.divider, strokeWidth: 1),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: sorted.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value,
                      color: colors[e.key % colors.length],
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...sorted.asMap().entries.map((entry) {
          final color = colors[entry.key % colors.length];
          final pct = entry.value.value / total;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Text(kPaymentIcons[entry.value.key] ?? '💰',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.value.key,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text('${(pct * 100).toStringAsFixed(1)}% of total',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Text(Formatters.currency(entry.value.value),
                    style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }),
        const SizedBox(height: 60),
      ],
    );
  }
}

class _TrendsTab extends StatelessWidget {
  final ExpenseProvider provider;
  const _TrendsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final expenses = provider.expenses;
    if (expenses.isEmpty) return _buildEmpty();

    // Daily spending in current month
    final Map<int, double> dailyMap = {};
    for (final e in expenses) {
      dailyMap[e.date.day] = (dailyMap[e.date.day] ?? 0) + e.amount;
    }

    final days = dailyMap.keys.toList()..sort();
    final spots = days.map((d) => FlSpot(d.toDouble(), dailyMap[d]!)).toList();

    final avgDaily = provider.getAverageDailySpend();
    final topCat = provider.topCategory;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats row
        Row(
          children: [
            _StatCard(
              label: 'Daily Avg',
              value: Formatters.shortCurrency(avgDaily),
              icon: '📊',
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Top Category',
              value: topCat,
              icon: kCategoryIcons[topCat] ?? '💰',
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Daily Spending',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (spots.isNotEmpty)
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppTheme.divider, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 9),
                      ),
                      interval: 5,
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        Formatters.shortCurrency(value),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 9),
                      ),
                      reservedSize: 44,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

Widget _buildEmpty() {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('📊', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text('No data yet',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        Text('Add expenses to see analytics',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
