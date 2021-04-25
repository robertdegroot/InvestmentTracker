import 'package:flutter/material.dart';
import 'package:investment_tracker/chart_data.dart';
import 'package:investment_tracker/databaseHelper.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:investment_tracker/investment_history_chart.dart';

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
          if (snapshot.hasData) {
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
                        setupChart(snapshot.data),
                        buildRow(investmentItem),
                      ],
                    );
                  } else {
                    return buildRow(investmentItem);
                  }
                },
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

  Widget setupChart(List<Map<String, dynamic>> inputData) {
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
      child: InvestmentHistoryChart(investmentChartData, updateChartData),
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
          "${timestampToString(investment.timestamp)} - ${investment.description}",
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
    return DateFormat('MMMEd').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
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
