
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/view/widget/expense_pie_chart.dart';

class ExamplePieChartCard extends StatelessWidget {

  ExamplePieChartCard();

  @override
  Widget build(BuildContext context) {
    return new Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(16.0),
        color: Colors.white54,
        dashPattern: [6, 5],
        child: ExpensePieChart(_createSampleData(), true),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  List<Expense> _createSampleData() {
    return [
      new Expense(1, 0, 700, "Rent", null),
      new Expense(2, 0, 200, "Groceries", null),
      new Expense(3, 0, 50, "Phone bill", null),
      new Expense(4, 0, 175, "Insurance", null),
    ];
  }
}