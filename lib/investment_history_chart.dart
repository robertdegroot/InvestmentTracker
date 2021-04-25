import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/chart_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class InvestmentHistoryChart extends StatelessWidget {
  final List<ChartData> investmentData;
  final List<ChartData> updateData;

  InvestmentHistoryChart(this.investmentData, this.updateData);

  @override
  Widget build(BuildContext context) {
    charts.RenderSpec<num> renderSpecPrimary = AxisTheme.axisThemeNum();
    charts.RenderSpec<DateTime> renderSpecDomain = AxisTheme.axisThemeDateTime();

    return Container(
      height: 300,
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          RichText(
            text: new TextSpan(
              children: <TextSpan>[
                new TextSpan(
                  text: 'Total investment',
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.deepOrange,
                  ),
                ),
                new TextSpan(
                  text: ' - ',
                  style: new TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                new TextSpan(
                  text: 'portfolio value',
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (charts.TimeSeriesChart(
              _createSeries(investmentData, updateData),
              defaultRenderer: new charts.LineRendererConfig(
                includePoints: true,
                includeArea: true,
              ),
              animate: true,
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false,
                ),
                renderSpec: renderSpecPrimary,
              ),
              domainAxis: charts.DateTimeAxisSpec(
                renderSpec: renderSpecDomain,
              ),
            )),
          )
        ],
      ),
    );
  }
}

List<charts.Series<ChartData, DateTime>> _createSeries(
    List<ChartData> investmentData, List<ChartData> updateData) {
  return [
    new charts.Series<ChartData, DateTime>(
      id: 'Investments',
      colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
      domainFn: (ChartData investment, _) => investment.timestamp,
      measureFn: (ChartData investment, _) => investment.price,
      data: investmentData,
    ),
    new charts.Series<ChartData, DateTime>(
      id: 'Updates',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (ChartData update, _) => update.timestamp,
      measureFn: (ChartData update, _) => update.price,
      data: updateData,
    )
  ];
}

class AxisTheme {
  static charts.RenderSpec<num> axisThemeNum() {
    return charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.gray.shade500,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.gray.shade500,
      ),
    );
  }

  static charts.RenderSpec<DateTime> axisThemeDateTime() {
    return charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.gray.shade500,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.transparent,
      ),
    );
  }
}