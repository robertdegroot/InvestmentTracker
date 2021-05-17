import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/model/investment/expense_chart_data.dart';
import 'package:collection/collection.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenseData;
  final bool isExampleChart;

  ExpensePieChart(this.expenseData, this.isExampleChart);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ExpenseChartData, String>> chartData = [];
    var chartText = _exampleChartTopText();

    chartData = _createSeries();

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

  Widget _exampleChartTopText() {
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

  List<charts.Series<ExpenseChartData, String>> _createSeries() {
    List<ExpenseChartData> chartData = [];

    expenseData.forEach((expense) {
      var expenseWithCategory = chartData.firstWhereOrNull((item) => item.category == expense.category);

      if (expenseWithCategory == null) {
        chartData.add(new ExpenseChartData(expense.category, expense.amount));
      } else {
        expenseWithCategory.amount += expense.amount;
      }

    });

    return [
      new charts.Series<ExpenseChartData, String>(
        id: 'Expenses',
        domainFn: (ExpenseChartData expense, _) => expense.category,
        measureFn: (ExpenseChartData expense, _) => expense.amount,
        data: chartData,
        labelAccessorFn: (ExpenseChartData row, _) =>
            '${row.amount}\n${row.category}',
        insideLabelStyleAccessorFn: (ExpenseChartData row, _) =>
            charts.TextStyleSpec(
          fontSize: 11, // size in Pts.
          color: charts.MaterialPalette.gray.shade800,
        ),
      )
    ];
  }
}