import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/model/investment/investment.dart';
import 'package:investment_tracker/model/investment/investment_chart_data.dart';
import 'investment_history_chart.dart';

class InvestmentChartCard extends StatelessWidget {
  final List<Investment> _data;

  InvestmentChartCard(this._data);

  Widget build(BuildContext context) {
    final List<InvestmentChartData> investmentChartDataPoints = [];
    final List<InvestmentChartData> portfolioChartDataPoints = [];

    Map investmentData = Map<DateTime, double>();
    Map portfolioData = Map<DateTime, double>();

    double totalInvestment = 0;

    _data.reversed.forEach((investment) {
      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(investment.timestamp);

      if (!investment.isInterimValue) {
        totalInvestment += investment.amount;

        investmentData[timestamp] = totalInvestment;
      } else {
        portfolioData[timestamp] = investment.amount;
      }
    });

    investmentData.forEach((timestamp, amount) {
      investmentChartDataPoints.add(InvestmentChartData(
          timestamp,
          amount,
          [2, 2],
          2.0
      ));
    });

    portfolioData.forEach((timestamp, amount) {
      portfolioChartDataPoints.add(InvestmentChartData(
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