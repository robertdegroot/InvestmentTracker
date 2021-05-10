import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/model/expense/expense_state.dart';
import 'package:investment_tracker/view/widget/add_expense_bottom_sheet.dart';
import 'package:investment_tracker/view/widget/tip_card.dart';
import 'package:investment_tracker/view_model/expense_view_model.dart';
import 'package:provider/provider.dart';

class ExpenseOverview extends StatefulWidget {
  @override State<StatefulWidget> createState() => _ExpenseOverviewState();
}

class _ExpenseOverviewState extends State<ExpenseOverview> {

  @override
  Widget build(BuildContext context) {
    final expenseViewModel = Provider.of<ExpenseViewModel>(context);

    return Scaffold(
        body: getExpenseWidget(context, expenseViewModel.response),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amberAccent,
          child: Icon(Icons.add),
          onPressed: () => showBottomSheet(),
        )
    );
  }

  Widget getExpenseWidget(BuildContext context, ExpenseState expenseState) {
    switch (expenseState.status) {
      case Status.LOADING:
        return new Container(
          alignment: AlignmentDirectional.center,
          child: new CircularProgressIndicator(),
        );
      case Status.ERROR:
        return Center(
          child: Text('Please try again later.'),
        );
      case Status.COMPLETED:
        return expenseListBuilder(expenseState.data);
      case Status.INITIAL:
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<ExpenseViewModel>(context, listen: false).getAllExpenses();
        });
        return new Container(
          alignment: AlignmentDirectional.center,
          child: new CircularProgressIndicator(),
        );
    }
  }

  ListView expenseListBuilder(List<Expense> expenseList) {
    if (expenseList != null && expenseList.isNotEmpty) {
      return new ListView.builder(
          itemCount: expenseList.length,
          itemBuilder: (context, index) {

            Expense expense = expenseList[index];
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
      );
    } else {
      return new ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            // if (index == 0 ) {
            //   return Column(
            //       children: [
            //         ExampleInvestmentChartCard(),
            //       ]
            //   );
            // } else
              if (index == 0){
              return TipCard(
                  "Log your first expense",
                  "Keeping track of all your expenses will give you the best overview here"
              );
            } else {
              return TipCard(
                  "Create your own categories",
                  "The categories are customizable and can be added or removed to your liking"
              );
            }
          }
      );
    }
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
        return AddExpenseBottomSheet();
      },
    );
  }

}

