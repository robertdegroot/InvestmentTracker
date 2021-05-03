class Investment {

  final int id;
  final int timestamp;
  final double amount;
  final String description;
  final bool isInterimValue;

  Investment(this.id, this.timestamp, this.amount, this.description, this.isInterimValue);

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'timestamp': timestamp,
      'amount': amount,
      'description': description,
      'is_interim_value': isInterimValue,
    };
  }

}
