import 'package:flutter/material.dart';
import 'package:investment_tracker/chart_data.dart';
import 'package:investment_tracker/databaseHelper.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:investment_tracker/investment_history_chart.dart';

import 'custom_date_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        child: Icon(Icons.add),
        onPressed: () => showBottomSheet(),
      )
    );

  }

  Widget setupChart(List<Map<String, dynamic>> investmentData) {
    final List<ChartData> data = [];
    Map monthlyData = Map<String, double>();

    investmentData.reversed.forEach((element) {
      String month = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(element['timestamp']));
      if (monthlyData[month] == null) {
        monthlyData[month] = element['amount'];
      } else {
        monthlyData[month] += element['amount'];
      }
    });

    monthlyData.forEach((month, amount) {
      data.add(ChartData(
        month,
        amount,
        charts.ColorUtil.fromDartColor(Colors.teal),
      ));
    });

    return new Card(
      child: InvestmentHistoryChart(data: data,),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  Widget buildRow(Investment investment) {
    Color backgroundColor = Colors.white;

    if (investment.isInterimValue) {
      backgroundColor = Colors.lightGreen;
    }

    return Card(
      child: ListTile(
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
                                Navigator.pop(context);
                              },
                              child: Text(
                                  'Submit',
                                 style: TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(24)
                                )
                              ),
                          )
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

class Investment {

  final int id;
  final int timestamp;
  final double amount;
  final String description;
  final bool isInterimValue;

  Investment(this.id, this.timestamp, this.amount, this.description, this.isInterimValue);

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'timestamp': timestamp,
      'amount': amount,
      'description': description,
      'is_interim_value': isInterimValue,
    };
  }

}

