import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:investment_tracker/model/investment/investment.dart';
import 'package:investment_tracker/view_model/investment_view_model.dart';
import 'package:provider/provider.dart';

class InvestmentCard extends StatelessWidget {
  final Investment investment;
  final Investment previousInvestment;

  InvestmentCard(this.investment, this.previousInvestment);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black12;
    final biggerFont = TextStyle(fontSize: 18.0);

    String changeString = "";

    Icon leadingIcon = Icon(Icons.trending_neutral);

    //TODO extract to update_card and expand with more information
    if (investment.isInterimValue) {
      backgroundColor = Colors.blueGrey;

      if (previousInvestment != null) {
        var difference = ((investment.amount - previousInvestment.amount) / previousInvestment.amount) * 100;

        String changeSuffix = "% increase";
        if (difference.isNegative) {
          difference *= -1;
          changeSuffix = "% decrease";
        }

        var differenceRounded = difference.roundToDouble() % 1 == 0 ? difference.toInt() : difference;
        changeString = "${differenceRounded.toString()}$changeSuffix";

        if (investment.amount > previousInvestment.amount) {
          backgroundColor = Colors.green;
          leadingIcon = Icon(Icons.trending_up);
        } else if (investment.amount < previousInvestment.amount) {
          backgroundColor = Colors.deepOrangeAccent;
          leadingIcon = Icon(Icons.trending_down);
        }
      }
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

    var cardSubtitle = investment.amount.toString();
    if (changeString.isNotEmpty) cardSubtitle += " - $changeString";

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
          cardSubtitle,
        ),
        trailing: new Column(
          children: <Widget>[
            new IconButton(
                onPressed: () {
                  Provider.of<InvestmentViewModel>(context, listen: false).deleteInvestment(investment);
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