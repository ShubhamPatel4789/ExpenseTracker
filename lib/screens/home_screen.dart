import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../providers/expense_provider.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExpensesScreen(),
    SizedBox(), // Placeholder for FAB
    AnalyticsScreen(),
    BudgetScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 2
          ? null
          : Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                onPressed: _openAddExpense,
                backgroundColor: AppTheme.primary,
                elevation: 8,
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
        height: 60,
        color: AppTheme.surface,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppTheme.primary,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.dashboard_rounded, color: Colors.white, size: 24),
          Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
          Icon(Icons.add_rounded, color: Colors.white, size: 28),
          Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
          Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 24),
        ],
        onTap: (index) {
          if (index == 2) {
            _openAddExpense();
            return;
          }
          setState(() {
            _currentIndex = index >= 2 ? index + 1 : index;
            if (index == 2) _currentIndex = 0;
          });
        },
      ),
    );
  }

  void _openAddExpense() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AddExpenseScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }
}
