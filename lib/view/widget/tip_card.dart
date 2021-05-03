import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'add_investment_bottom_sheet.dart';

class TipCard extends StatelessWidget {
  final String title;
  final String subtitle;

  TipCard(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    final biggerFont = TextStyle(fontSize: 18.0);

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
          onTap: () { showBottomSheet(context); },
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
              title,
              style: biggerFont,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(bottom: 8.0, right: 8.0),
            child: Text(
              subtitle,
            ),
          ),
        ),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
    );
  }

  String timestampToString(int timestamp) {
    return DateFormat('MMMd').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return AddInvestmentBottomSheet();
      },
    );
  }

}