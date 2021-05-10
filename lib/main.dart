import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:investment_tracker/view/screen/expense_overview.dart';
import 'package:investment_tracker/view/screen/investment_overview.dart';
import 'package:investment_tracker/view_model/expense_view_model.dart';
import 'package:investment_tracker/view_model/investment_view_model.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: InvestmentViewModel()),
        ChangeNotifierProvider.value(value: ExpenseViewModel()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: TabLayoutWidget(),
      ),
    );
  }
}

class TabLayoutWidget extends StatefulWidget {
  const TabLayoutWidget({Key key}) : super(key: key);

  @override
  _TabLayoutWidgetState createState() => _TabLayoutWidgetState();
}

class _TabLayoutWidgetState extends State<TabLayoutWidget> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ExpenseOverview(),
    InvestmentOverview(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_rounded),
            label: 'Investments',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amberAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

