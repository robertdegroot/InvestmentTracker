import 'package:flutter/material.dart';
import 'package:investment_tracker/chart_data.dart';
import 'package:investment_tracker/databaseHelper.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:investment_tracker/investment_history_chart.dart';

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

  final dateController = new TextEditingController();
  final descriptionController = new TextEditingController();
  final amountController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Investment overview"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllInvestments(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                if (index == 0) return setupChart(snapshot.data);
                else return buildRow(
                    Investment(
                      snapshot.data[index]['_id'],
                      snapshot.data[index]['timestamp'],
                      snapshot.data[index]['amount'],
                      snapshot.data[index]['description'],
                      snapshot.data[index]['is_interim_value'] == 0
                          ? false
                          : true,
                    ));
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
    return Card(
      child: ListTile(
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
    return DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  // void showBottomSheet(BuildContext ctx) {
  //   showModalBottomSheet(
  //       isScrollControlled: true,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16.0)
  //       ),
  //       elevation: 5,
  //       context: ctx,
  //       builder: (ctx) => Padding(
  //         padding: EdgeInsets.all(15),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // TextField(
  //             //   keyboardType: TextInputType.datetime,
  //             //   decoration: InputDecoration(labelText: 'Date'),
  //             //   controller: dateController,
  //             // ),
  //             TextField(
  //               keyboardType: TextInputType.number,
  //               decoration: InputDecoration(labelText: 'Amount'),
  //               controller: amountController,
  //             ),
  //             TextField(
  //               keyboardType: TextInputType.text,
  //               decoration: InputDecoration(labelText: 'Description'),
  //               controller: descriptionController,
  //             ),
  //             SizedBox(
  //               height: 15,
  //             ),
  //             ElevatedButton(onPressed: () { saveInputs(); }, child: Text('Submit'))
  //           ],
  //         ),
  //       ));
  // }

  void showBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                margin: EdgeInsets.all(16.0),
                child: Wrap(
                  children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Amount'),
                      controller: amountController,
                    ),
                    TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Description'),
                      controller: descriptionController,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          saveInputs();
                          Navigator.pop(context);
                        },
                        child: Text('Submit'))
                  ],
                )));
      },
    );
  }

  saveInputs() {
    var date = dateController.text;
    var amount = amountController.text.toString();
    var description = descriptionController.text.toString();

    var investment = Investment(
        null,
        DateTime.now().millisecondsSinceEpoch,
        double.parse(amount),
        description,
        false
    );

    _insert(investment);
  }

  Future<List<Map<String, dynamic>>> _getAllInvestments() async {
    return dbHelper.queryAllInvestments();
  }

  Future<List<Map<String, dynamic>>> _getAllInterimValues() async {
    return dbHelper.queryAllInterimValues();
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

