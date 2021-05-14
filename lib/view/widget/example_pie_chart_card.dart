
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/view/widget/expense_pie_chart.dart';

class ExamplePieChartCard extends StatelessWidget {

  ExamplePieChartCard();

  @override
  Widget build(BuildContext context) {
    final List<Expense> _expenseChartData = [];

    return new Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(16.0),
        color: Colors.white54,
        dashPattern: [6, 5],
        child: ExpensePieChart(_expenseChartData, true),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }
}