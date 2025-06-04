import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expense.dart';
import 'expense_provider.dart';
import 'theme_provider.dart';

class AddExpenseForm extends StatefulWidget {
  final int? index;

  const AddExpenseForm({super.key, this.index});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  String? _type;
  double? _amount;
  String? _comment;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final expense = widget.index != null ? expenseProvider.expenses[widget.index!] : null;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.index != null ? 'Edit Expense' : 'Add New Expense',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type ?? expense?.type,
              decoration: const InputDecoration(labelText: 'Expense Type'),
              items: expenseProvider.expenseTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _type = value),
              validator: (value) => value == null ? 'Please select a type' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: expense?.amount.toString(),
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter an amount';
                if (double.tryParse(value) == null) return 'Enter a valid number';
                return null;
              },
              onSaved: (value) => _amount = double.parse(value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: expense?.comment,
              decoration: const InputDecoration(labelText: 'Comment'),
              onSaved: (value) => _comment = value,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          onSurface: isDark ? Colors.white : Colors.black,
                        ), dialogTheme: DialogThemeData(backgroundColor: isDark ? Colors.grey[850] : Colors.white),
                      ),
                      child: child!,
                    );
                  },
                );
                if (selectedDate != null) {
                  setState(() => _date = selectedDate);
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text('Date: ${DateFormat.yMMMd().format(_date)}'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newExpense = Expense(
                    type: _type!,
                    amount: _amount!,
                    comment: _comment ?? '',
                    date: _date,
                  );
                  if (widget.index != null) {
                    expenseProvider.updateExpense(widget.index!, newExpense);
                  } else {
                    expenseProvider.addExpense(newExpense);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(widget.index != null ? 'Update Expense' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
