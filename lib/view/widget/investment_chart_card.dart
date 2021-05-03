import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/model/chart_data.dart';
import 'investment_history_chart.dart';

class InvestmentChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> _data;

  InvestmentChartCard(this._data);

  Widget build(BuildContext context) {
    final List<ChartData> investmentChartDataPoints = [];
    final List<ChartData> portfolioChartDataPoints = [];

    Map investmentData = Map<DateTime, double>();
    Map portfolioData = Map<DateTime, double>();

    double totalInvestment = 0;

    _data.reversed.forEach((element) {
      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(element['timestamp']);

      if (element['is_interim_value'] == 0) {
        totalInvestment += element['amount'];

        investmentData[timestamp] = totalInvestment;
      } else {
        portfolioData[timestamp] = element['amount'];
      }
    });

    investmentData.forEach((timestamp, amount) {
      investmentChartDataPoints.add(ChartData(
          timestamp,
          amount,
          [2, 2],
          2.0
      ));
    });

    portfolioData.forEach((timestamp, amount) {
      portfolioChartDataPoints.add(ChartData(
          timestamp,
          amount,
          [1, 3],
          3.0
      ));
    });

    return new Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: InvestmentHistoryChart(investmentChartDataPoints, portfolioChartDataPoints, false),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }
}