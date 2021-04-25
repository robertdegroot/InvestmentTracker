import 'package:charts_flutter/flutter.dart' as charts;

class ChartData {

  final DateTime timestamp;
  final double price;
  final List<int> dashPattern;
  final double strokeWidthPx;

  ChartData(this.timestamp, this.price, this.dashPattern, this.strokeWidthPx);

}