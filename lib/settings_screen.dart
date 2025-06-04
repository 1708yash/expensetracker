import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          hintText: 'New Expense Type',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                      onPressed: () {
                        final newType = _typeController.text.trim();
                        if (newType.isNotEmpty &&
                            !expenseProvider.expenseTypes.contains(newType)) {
                          expenseProvider.addExpenseType(newType);
                          _typeController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added "$newType"')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: expenseProvider.expenseTypes.length,
                itemBuilder: (context, index) {
                  final type = expenseProvider.expenseTypes[index];
                  final isDefault = ['Food', 'Transport', 'Entertainment', 'Utilities', 'Others']
                      .contains(type);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.label, color: Colors.green),
                      title: Text(type),
                      trailing: isDefault
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          expenseProvider.removeExpenseType(type);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed "$type"')),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
