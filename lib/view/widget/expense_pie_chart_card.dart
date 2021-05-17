import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/view/widget/expense_pie_chart.dart';

class ExpensePieChartCard extends StatelessWidget {
  final List<Expense> _data;

  ExpensePieChartCard(this._data);

  @override
  Widget build(BuildContext context) {
    return new Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: ExpensePieChart(_data, false),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }
}