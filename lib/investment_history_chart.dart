import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/chart_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class InvestmentHistoryChart extends StatelessWidget {
  final List<ChartData> data;

  InvestmentHistoryChart({@required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ChartData, String>> series = [
      charts.Series(
          id: "Price",
          data: data,
          domainFn: (ChartData series, _) => series.date,
          measureFn: (ChartData series, _) => series.price,
          colorFn: (ChartData series, _) => series.color)
    ];

    return Container(
      height: 300,
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Text(
            "Investment per month",
          ),
          Expanded(
            child: (charts.BarChart(series, animate: true)),
          )
        ],
      ),
    );
  }
}