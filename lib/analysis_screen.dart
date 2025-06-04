import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'expense.dart';
import 'expense_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k';
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    // Group expenses by date
    final Map<DateTime, double> dailyTotals = {};
    for (var expense in expenses) {
      final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
    }

    final selectedDate = _selectedDay ?? _focusedDay;
    final selectedDayTotal = dailyTotals[DateTime(selectedDate.year, selectedDate.month, selectedDate.day)] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                outsideDaysVisible: false,
                defaultTextStyle: GoogleFonts.poppins(),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final total = dailyTotals[DateTime(day.year, day.month, day.day)];
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSameDay(day, _selectedDay)
                          ? Colors.green[600]
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${day.day}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: isSameDay(day, _selectedDay) ? Colors.white : null)),
                        if (total != null)
                          Text(
                            '₹${formatAmount(total)}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: isSameDay(day, _selectedDay)
                                  ? Colors.white70
                                  : Colors.green[700],
                            ),
                          ),
                      ],
                    ),
                  );
                },
                todayBuilder: (context, day, _) {
                  final total = dailyTotals[DateTime(day.year, day.month, day.day)];
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${day.day}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        if (total != null)
                          Text(
                            '₹${formatAmount(total)}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Total spent on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}: ₹${formatAmount(selectedDayTotal)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
              ),
            ),

            SfCircularChart(
              title: ChartTitle(
                text: 'Expense Distribution',
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              legend: Legend(isVisible: true),
              series: <CircularSeries<Expense, String>>[
                PieSeries<Expense, String>(
                  dataSource: expenses,
                  xValueMapper: (Expense exp, _) => exp.type,
                  yValueMapper: (Expense exp, _) => exp.amount,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SfCartesianChart(
              title: ChartTitle(
                text: 'Expenses Over Time',
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              primaryXAxis: DateTimeAxis(),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                    text: 'Amount (₹)', textStyle: GoogleFonts.poppins()),
              ),
              series: <CartesianSeries<Expense, DateTime>>[
                LineSeries<Expense, DateTime>(
                  dataSource: expenses,
                  xValueMapper: (Expense exp, _) => exp.date,
                  yValueMapper: (Expense exp, _) => exp.amount,
                  color: Colors.green,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
