import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/model/expense/expense_state.dart';
import 'package:investment_tracker/view/widget/add_expense_bottom_sheet.dart';
import 'package:investment_tracker/view/widget/example_pie_chart_card.dart';
import 'package:investment_tracker/view/widget/expense_card.dart';
import 'package:investment_tracker/view/widget/expense_pie_chart_card.dart';
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
    print(expenseState.message);
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
      case Status.EMPTY:
        return expenseEmptyState();
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
    return new ListView.builder(
        itemCount: expenseList.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                ExpensePieChartCard(expenseList),
                ExpenseCard(expenseList[index]),
              ],
            );
          } else {
            return ExpenseCard(expenseList[index]);
          }
        });
  }

  ListView expenseEmptyState() {
    return new ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          if (index == 0 ) {
            return Column(
                children: [
                  ExamplePieChartCard(),
                ]
            );
          } else
          if (index == 1){
            return TipCard(
                "Log your first expense",
                "Keeping track of all your expenses will give you the best overview here",
                BottomSheetType.EXPENSE
            );
          } else {
            return TipCard(
                "Create your own categories",
                "The categories are customizable and can be added or removed to your liking",
                BottomSheetType.EXPENSE
            );
          }
        }
    );
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

