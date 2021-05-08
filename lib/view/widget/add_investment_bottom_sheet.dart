import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investment_tracker/model/investment.dart';
import 'package:provider/provider.dart';
import 'custom_date_picker.dart';
import 'package:investment_tracker/view_model/investment_view_model.dart';

class AddInvestmentBottomSheet extends StatefulWidget {
  @override _AddInvestmentBottomSheetState createState() => _AddInvestmentBottomSheetState();
}

class _AddInvestmentBottomSheetState extends State<AddInvestmentBottomSheet> {
  final descriptionController = new TextEditingController();
  final amountController = new TextEditingController();

  DateTime pickedDate = DateTime.now();
  bool isTotalValue = false;

  @override
  Widget build(BuildContext context) {
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
                            pickedDate = selectedDate;
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
                            saveInput(context);
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
  }

  saveInput(BuildContext context) {
    var amount = amountController.text.toString();
    var description = descriptionController.text.toString();

    var investment = Investment(
        null,
        DateTime(pickedDate.year, pickedDate.month, pickedDate.day).millisecondsSinceEpoch,
        double.parse(amount),
        description,
        isTotalValue
    );

    Provider.of<InvestmentViewModel>(context, listen: false).insertInvestment(investment);
  }

}