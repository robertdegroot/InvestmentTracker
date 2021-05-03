import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/model/chart_data.dart';
import 'investment_history_chart.dart';

class ExampleChartCard extends StatelessWidget {

  ExampleChartCard();

  @override
  Widget build(BuildContext context) {
    final List<ChartData> _investmentChartData = [];
    final List<ChartData> _updateChartData = [];

    var _list = new List<int>.generate(20, (i) => i + 1);
    var _today = DateTime.now();

    Map _investmentData = Map<DateTime, double>();
    Map _updateData = Map<DateTime, double>();

    double _totalInvestment = 0;
    double _totalPortfolio = 0;

    _list.reversed.forEach((iteration) {
      Random randomValue = new Random();
      final DateTime timestamp = new DateTime(_today.year, _today.month - iteration, _today.day);
      final addValue = (randomValue.nextInt(1250 + 250) - 250);

      _totalInvestment += addValue.toDouble();
      _totalPortfolio = _totalPortfolio + addValue.toDouble() + (randomValue.nextInt(850 + 750) - 750);

      _investmentData[timestamp] = _totalInvestment;
      _updateData[timestamp] = _totalPortfolio;
    });

    _investmentData.forEach((timestamp, amount) {
      _investmentChartData.add(ChartData(
          timestamp,
          amount,
          [2, 2],
          2.0
      ));
    });

    _updateData.forEach((timestamp, amount) {
      _updateChartData.add(ChartData(
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
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(16.0),
        color: Colors.white54,
        dashPattern: [6, 5],
        child: InvestmentHistoryChart(_investmentChartData, _updateChartData, true),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }
}