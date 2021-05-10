import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/view_model/expense_view_model.dart';
import 'package:provider/provider.dart';
import 'custom_date_picker.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  @override _AddExpenseBottomSheetState createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final noteController = new TextEditingController();
  final amountController = new TextEditingController();
  final categoryController = new TextEditingController();

  DateTime pickedDate = DateTime.now();

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
                              hintText: 'Category'),
                          controller: categoryController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Optional note'),
                          controller: noteController,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            saveInput(context);
                            amountController.text = "";
                            categoryController.text = "";
                            noteController.text = "";
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
    var note = noteController.text.toString();
    var category = categoryController.text.toString();

    var expense = Expense(
        null,
        DateTime(pickedDate.year, pickedDate.month, pickedDate.day).millisecondsSinceEpoch,
        double.parse(amount),
        category,
        note
    );

    Provider.of<ExpenseViewModel>(context, listen: false).insertExpense(expense);
  }

}