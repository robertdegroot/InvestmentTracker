import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:investment_tracker/model/investment.dart';
import 'package:investment_tracker/view_model/investment_view_model.dart';
import 'package:provider/provider.dart';

class InvestmentCard extends StatelessWidget {
  final Investment investment;

  InvestmentCard(this.investment);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black12;
    final biggerFont = TextStyle(fontSize: 18.0);

    //TODO build color coding
    Icon leadingIcon = Icon(Icons.trending_neutral);
    double previousUpdate = 0;

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
          style: biggerFont,
        ),
        subtitle: Text(
          investment.amount.toString(),
        ),
        trailing: new Column(
          children: <Widget>[
            new IconButton(
                onPressed: () {
                  Provider.of<InvestmentViewModel>(context, listen: false)
                      .deleteInvestment(investment);
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