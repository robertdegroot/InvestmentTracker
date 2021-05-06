import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/view/screen/investment_overview_screen.dart';
import 'package:investment_tracker/view_model/investment_view_model.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: InvestmentViewModel()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => InvestmentOverview(),
        },
      ),
    );
  }
}