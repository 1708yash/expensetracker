

class Expense {
  final String type;
  final double amount;
  final String comment;
  final DateTime date;

  Expense({
    required this.type,
    required this.amount,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'comment': comment,
    'date': date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    type: json['type'],
    amount: json['amount'],
    comment: json['comment'],
    date: DateTime.parse(json['date']),
  );
}