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
    List<charts.Series<ExpenseChartData, String>> chartData = [];
    var chartText = exampleChartTopText();

    // if (isExampleChart) {
      chartText = exampleChartTopText();
      chartData = _createSampleData();
    // }

    return Container(
      height: 400,
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          chartText,
          Expanded(
            child: (charts.PieChart(
              chartData,
              animate: true,
              defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 120,
                  arcRendererDecorators: [
                    new charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.inside,
                    )
                  ]),
            )),
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

List<charts.Series<ExpenseChartData, String>> _createSampleData() {
  final data = [
    new ExpenseChartData("Rent", 700),
    new ExpenseChartData("Groceries", 200),
    new ExpenseChartData("Phone bill", 50),
    new ExpenseChartData("Insurance", 175),
  ];

  return [
    new charts.Series<ExpenseChartData, String>(
      id: 'Expenses',
      domainFn: (ExpenseChartData expense, _) => expense.category,
      measureFn: (ExpenseChartData expense, _) => expense.price,
      data: data,
      labelAccessorFn: (ExpenseChartData row, _) => '${row.price}\n${row.category}',
      insideLabelStyleAccessorFn: (ExpenseChartData row, _) => charts.TextStyleSpec(
          fontSize: 11, // size in Pts.
          color: charts.MaterialPalette.gray.shade800,
      ),
    )
  ];
}