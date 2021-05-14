import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/model/investment/expense_chart_data.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenseChartData;
  final bool isExampleChart;

  ExpensePieChart(this.expenseChartData, this.isExampleChart);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ExpenseChartData, int>> chartData = [];
    var chartText = exampleChartTopText();

    // if (isExampleChart) {
      chartText = exampleChartTopText();
      chartData = _createSampleData();
    // }

    return Container(
      height: 300,
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          chartText,
          Expanded(
            child: (charts.PieChart(chartData,
                animate: true,
                defaultRenderer: new charts.ArcRendererConfig(
                    arcWidth: 80,
                    arcRendererDecorators: [new charts.ArcLabelDecorator()]))
            ),
          )
        ],
      ),
    );
  }

  Widget exampleChartTopText() {
    return RichText(
      text: new TextSpan(
        children: <TextSpan>[
          new TextSpan(
            text: 'This is an example chart',
            style: new TextStyle(
              fontSize: 14.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

List<charts.Series<ExpenseChartData, int>> _createSampleData() {
  final data = [
    new ExpenseChartData(1, "Rent", 700),
    new ExpenseChartData(2, "Groceries", 200),
    new ExpenseChartData(3, "Phone bill", 50),
    new ExpenseChartData(4, "Insurance", 175),
  ];

  return [
    new charts.Series<ExpenseChartData, int>(
      id: 'Expenses',
      domainFn: (ExpenseChartData expense, _) => expense.id,
      measureFn: (ExpenseChartData expense, _) => expense.price,
      data: data,
      labelAccessorFn: (ExpenseChartData row, _) => '${row.category} - ${row.price}',
    )
  ];
}