import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expense_provider.dart';
import 'theme_provider.dart';
import 'add_expense_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Define green-themed colors
    final primaryColor = isDarkMode ? Colors.green.shade800 : Colors.green.shade400;
    final accentColor = isDarkMode ? Colors.greenAccent.shade700 : Colors.greenAccent.shade200;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final cardColor = isDarkMode ? Colors.grey.shade50 : Colors.green.shade50;

    // Aggregate expenses by type for the chart
    final Map<String, double> expenseByType = {};
    for (var expense in expenseProvider.expenses) {
      expenseByType[expense.type] = (expenseByType[expense.type] ?? 0) + expense.amount;
    }
    final chartData = expenseByType.entries
        .map((entry) => ExpenseChartData(entry.key, entry.value))
        .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/analysis'),
          ),
        ],
      ),
        body: Column(
          children: [
            // Chart Container
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.white,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SfCartesianChart(
                title: ChartTitle(
                  text: 'Expenses by Category',
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                primaryXAxis: CategoryAxis(
                  labelStyle: GoogleFonts.poppins(),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: 'Amount (₹)',
                    textStyle: GoogleFonts.poppins(),
                  ),
                  minimum: 0,
                  maximum: chartData.isNotEmpty
                      ? chartData.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.2
                      : 1000,
                ),
                series: <CartesianSeries<ExpenseChartData, String>>[
                  ColumnSeries<ExpenseChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ExpenseChartData data, _) => data.type,
                    yValueMapper: (ExpenseChartData data, _) => data.amount,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, duration: 500.ms),

            // Total Spent This Month
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
                      offset: const Offset(4, 4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'Total Spent This Month: ₹${expenseProvider.expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),

            // Expenses List
            Expanded(
              child: ListView.builder(
                itemCount: expenseProvider.expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenseProvider.expenses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: cardColor,
                    child: ListTile(
                      title: Text(
                        expense.type,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        expense.comment,
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: Text(
                        '₹${expense.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => AddExpenseForm(index: index),
                        );
                      },
                      onLongPress: () {
                        expenseProvider.deleteExpense(index);
                      },
                    ),
                  ).animate().fadeIn(
                    delay: (index * 100).ms,
                    duration: 300.ms,
                  );
                },
              ),
            ),
          ],
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddExpenseForm(),
          );
        },
        backgroundColor: accentColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(duration: 300.ms),
    );
  }
}

class ExpenseChartData {
  final String type;
  final double amount;

  ExpenseChartData(this.type, this.amount);
}
