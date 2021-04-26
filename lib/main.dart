import 'dart:math';

import 'package:flutter/material.dart';
import 'package:investment_tracker/chart_data.dart';
import 'package:investment_tracker/databaseHelper.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:investment_tracker/investment_history_chart.dart';
import 'package:dotted_border/dotted_border.dart';
import 'custom_date_picker.dart';
import 'investment.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: "Investment Tracker",
      home: Investments(),
    );
  }
}

class Investments extends StatefulWidget {
  @override
  _InvestmentState createState() => _InvestmentState();
}

class _InvestmentState extends State<Investments> {
  final dbHelper = DatabaseHelper.instance;
  final _biggerFont = TextStyle(fontSize: 18.0);

  final descriptionController = new TextEditingController();
  final amountController = new TextEditingController();

  int pickedDate = DateTime.now().millisecondsSinceEpoch;
  bool isTotalValue = false;
  double previousUpdate = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllInvestments(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {

                  Investment investmentItem = Investment(
                    snapshot.data[index]['_id'],
                    snapshot.data[index]['timestamp'],
                    snapshot.data[index]['amount'],
                    snapshot.data[index]['description'],
                    snapshot.data[index]['is_interim_value'] == 0
                        ? false
                        : true,
                  );

                  if (index == 0) {
                    return Column(
                      children: [
                        _setupChart(snapshot.data),
                        buildRow(investmentItem),
                      ],
                    );
                  } else {
                    return buildRow(investmentItem);
                  }
                },
              );
            } else {
            return new ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                if (index == 0 ) {
                  return Column(
                    children: [
                      _exampleChart(),
                    ]
                  );
                } else if (index == 1){
                  return _tipCard(
                      "Log your first investment!",
                      "Keep track of all your investments by logging them in the app. You can also add investments to a past date."
                  );
                } else {
                  return _tipCard(
                      "Keep your portfolio total up to date!",
                      "Updating your total portfolio regularly will give you the best overview."
                  );
                }
              }
            );
          }

            return new Container(
            alignment: AlignmentDirectional.center,
            child: new CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        child: Icon(Icons.add),
        onPressed: () => showBottomSheet(),
      )
    );

  }

  Widget _setupChart(List<Map<String, dynamic>> inputData) {
    final List<ChartData> investmentChartData = [];
    final List<ChartData> updateChartData = [];

    Map investmentData = Map<DateTime, double>();
    Map updateData = Map<DateTime, double>();

    double totalInvestment = 0;

    inputData.reversed.forEach((element) {
      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(element['timestamp']);

      if (element['is_interim_value'] == 0) {
        totalInvestment += element['amount'];

        investmentData[timestamp] = totalInvestment;
      } else {
        updateData[timestamp] = element['amount'];
      }
    });

    investmentData.forEach((timestamp, amount) {
      investmentChartData.add(ChartData(
          timestamp,
          amount,
          [2, 2],
          2.0
      ));
    });

    updateData.forEach((timestamp, amount) {
      updateChartData.add(ChartData(
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
      child: InvestmentHistoryChart(investmentChartData, updateChartData, false),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  Widget _exampleChart() {
    final List<ChartData> investmentChartData = [];
    final List<ChartData> updateChartData = [];

    var list = new List<int>.generate(20, (i) => i + 1);
    var today = DateTime.now();

    Map investmentData = Map<DateTime, double>();
    Map updateData = Map<DateTime, double>();

    double totalInvestment = 0;
    double totalPortfolio = 0;

    list.reversed.forEach((iteration) {
      Random randomValue = new Random();
      final DateTime timestamp = new DateTime(today.year, today.month - iteration, today.day);
      final addValue = (randomValue.nextInt(1250 + 250) - 250);

      totalInvestment += addValue.toDouble();
      totalPortfolio = totalPortfolio + addValue.toDouble() + (randomValue.nextInt(850 + 750) - 750);

      investmentData[timestamp] = totalInvestment;
      updateData[timestamp] = totalPortfolio;
    });

    investmentData.forEach((timestamp, amount) {
      investmentChartData.add(ChartData(
          timestamp,
          amount,
          [2, 2],
          2.0
      ));
    });

    updateData.forEach((timestamp, amount) {
      updateChartData.add(ChartData(
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
        child: InvestmentHistoryChart(investmentChartData, updateChartData, true),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  Widget buildRow(Investment investment) {
    Color backgroundColor = Colors.black12;

    //TODO color coding not always correct
    Icon leadingIcon = Icon(Icons.trending_neutral);

    if (investment.isInterimValue) {
      backgroundColor = Colors.blueGrey;

      if (previousUpdate != 0) {
        if (investment.amount > previousUpdate) {
          backgroundColor = Colors.green;
          leadingIcon = Icon(Icons.trending_up);
        } else if (investment.amount < previousUpdate) {
          backgroundColor = Colors.deepOrangeAccent;
          leadingIcon = Icon(Icons.trending_down);
        }
      }
      previousUpdate = investment.amount;
    } else {
      if (investment.amount.isNegative) {
        leadingIcon = Icon(Icons.remove);
      } else {
        leadingIcon = Icon(Icons.add);
      }
    }

    var cardTitle = "";

    if (investment.isInterimValue) {
      if (investment.description.isNotEmpty) {
        cardTitle += "${timestampToString(investment.timestamp)} - ${investment.description}";
      } else {
        cardTitle = "Portfolio on ${timestampToString(investment.timestamp)}";
      }
    } else {
      cardTitle = "${timestampToString(investment.timestamp)}";

      if (investment.description.isNotEmpty) {
        cardTitle += " - ${investment.description}";
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        leading: new Column(
          children: <Widget>[
            new IconButton(
                icon: leadingIcon,
            )],
        ),
        tileColor: backgroundColor,
        title: Text(
          cardTitle,
          style: _biggerFont,
        ),
        subtitle: Text(
          investment.amount.toString(),
        ),
        trailing: new Column(
          children: <Widget>[
            new IconButton(
                onPressed: () { _deleteRow(investment.id); },
                icon: new Icon(Icons.delete)),
          ],
        ),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  String timestampToString(int timestamp) {
    return DateFormat('MMMd').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: Wrap(
                    children: <Widget>[
                      CheckboxListTile(
                        activeColor: Colors.amberAccent,
                        checkColor: Colors.black,
                        title: Text("Portfolio value update"),
                        value: isTotalValue,
                        autofocus: false,
                        selected: isTotalValue,
                        onChanged: (bool newValue) {
                          setState(() {
                            isTotalValue = newValue;
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: CustomDatePicker(
                          prefixIcon: Icon(Icons.date_range),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          lastDate: DateTime.now().add(Duration(days: 366)),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 1830)),
                          initialDate: DateTime.now(),
                          onDateChanged: (selectedDate) {
                            pickedDate = selectedDate.millisecondsSinceEpoch;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), hintText: 'Amount'),
                          controller: amountController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Optional description'),
                          controller: descriptionController,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                          child: ElevatedButton(
                              onPressed: () {
                                saveInputs();
                                isTotalValue = false;
                                amountController.text = "";
                                descriptionController.text = "";
                                Navigator.pop(context);
                              },
                              child: Text(
                                  'Submit',
                                  style: TextStyle(
                                     fontSize: 20, color: Colors.black
                                  ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(16.0)
                                ),
                                padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
                                primary: Colors.amberAccent,
                                onPrimary: Colors.black,
                              ),
                          ),
                      ),
                    ],
                  )));
        });
      },
    );
  }

  Widget _tipCard(String titleText, String subtitleText) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(16.0),
        color: Colors.white54,
        dashPattern: [6, 5],
        child: ListTile(
          onTap: () { showBottomSheet(); },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.white54)
            ],
          ),
          tileColor: Colors.black12,
          title: Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
            child: Text(
              titleText,
              style: _biggerFont,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(bottom: 8.0, right: 8.0),
            child: Text(
              subtitleText,
            ),
          ),
        ),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  saveInputs() {
    var amount = amountController.text.toString();
    var description = descriptionController.text.toString();

    var investment = Investment(
        null,
        pickedDate,
        double.parse(amount),
        description,
        isTotalValue
    );

    _insert(investment);
  }

  Future<List<Map<String, dynamic>>> _getAllInvestments() async {
    return dbHelper.queryAllRows();
  }
  
  _insert(Investment investment) async {
    await dbHelper.insert(investment.toMap());
    setState(() {});
  }

  _deleteRow(int id) {
    dbHelper.delete(id);
    setState(() {});
  }
}
