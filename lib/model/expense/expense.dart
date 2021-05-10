class Expense {

  final int id;
  final int timestamp;
  final double amount;
  final String category;
  final String note;

  Expense(this.id, this.timestamp, this.amount, this.category, this.note);

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'timestamp': timestamp,
      'amount': amount,
      'category': category,
      'note': note,
    };
  }

}
