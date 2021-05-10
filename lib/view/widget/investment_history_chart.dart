import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:investment_tracker/model/investment/investment_chart_data.dart';

class InvestmentHistoryChart extends StatelessWidget {
  final List<InvestmentChartData> investmentData;
  final List<InvestmentChartData> updateData;
  final bool isExampleChart;

  InvestmentHistoryChart(this.investmentData, this.updateData, this.isExampleChart);

  @override
  Widget build(BuildContext context) {
    charts.RenderSpec<num> renderSpecPrimary = AxisTheme.axisThemeNum();
    charts.RenderSpec<DateTime> renderSpecDomain = AxisTheme.axisThemeDateTime();

    var chartText = chartTopText();

    if (isExampleChart) {
      chartText = exampleChartTopText();
    }

    return Container(
      height: 300,
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          chartText,
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

  Widget chartTopText() {
    return RichText(
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
    );
  }
}

List<charts.Series<InvestmentChartData, DateTime>> _createSeries(
    List<InvestmentChartData> investmentData, List<InvestmentChartData> updateData) {
  return [
    new charts.Series<InvestmentChartData, DateTime>(
      id: 'Investments',
      colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
      domainFn: (InvestmentChartData investment, _) => investment.timestamp,
      measureFn: (InvestmentChartData investment, _) => investment.price,
      data: investmentData,
    ),
    new charts.Series<InvestmentChartData, DateTime>(
      id: 'Updates',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (InvestmentChartData update, _) => update.timestamp,
      measureFn: (InvestmentChartData update, _) => update.price,
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