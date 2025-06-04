import 'package:flutter/material.dart';
import 'expense.dart';
import 'storage_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  final List<String> _defaultTypes = [
    'Food',
    'Transport',
    'Entertainment',
    'Utilities',
    'Others',
  ];

  final List<String> _expenseTypes = [];

  final StorageService _storageService = StorageService();

  List<Expense> get expenses => _expenses;
  List<String> get expenseTypes => [..._defaultTypes, ..._expenseTypes.toSet().difference(_defaultTypes.toSet())];

  ExpenseProvider() {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    _expenses = await _storageService.loadExpenses();
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
    _storageService.saveExpenses(_expenses);
  }

  void deleteExpense(int index) {
    if (index >= 0 && index < _expenses.length) {
      _expenses.removeAt(index);
      notifyListeners();
      _storageService.saveExpenses(_expenses);
    }
  }

  void updateExpense(int index, Expense expense) {
    if (index >= 0 && index < _expenses.length) {
      _expenses[index] = expense;
      notifyListeners();
      _storageService.saveExpenses(_expenses);
    }
  }

  void addExpenseType(String type) {
    if (!_defaultTypes.contains(type) && !_expenseTypes.contains(type)) {
      _expenseTypes.add(type);
      notifyListeners();
    }
  }

  void removeExpenseType(String type) {
    if (_expenseTypes.contains(type)) {
      _expenseTypes.remove(type);
      notifyListeners();
    }
  }
}
