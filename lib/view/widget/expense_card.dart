import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/view_model/expense_view_model.dart';
import 'package:provider/provider.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  ExpenseCard(this.expense);

  @override
  Widget build(BuildContext context) {
    final biggerFont = TextStyle(fontSize: 18.0);

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
              icon: Icon(Icons.remove),
            )],
        ),
        tileColor: Colors.black12,
        title: Text(
          expense.category,
          style: biggerFont,
        ),
        subtitle: Text(
          "${expense.amount}",
        ),
        trailing: new Column(
          children: <Widget>[
            new IconButton(
                onPressed: () {
                  Provider.of<ExpenseViewModel>(context, listen: false).deleteExpense(expense);
                },
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
}