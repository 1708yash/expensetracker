import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'expense.dart';

class StorageService {
  Future<void> saveExpenses(List<Expense> expenses) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/expenses.json');
    final jsonString = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<List<Expense>> loadExpenses() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/expenses.json');
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json)).toList();
    }
    return [];
  }
}