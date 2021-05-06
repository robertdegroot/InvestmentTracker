import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investment_tracker/model/investment_state.dart';
import 'package:investment_tracker/model/investment.dart';
import 'package:investment_tracker/view/widget/add_investment_bottom_sheet.dart';
import 'package:investment_tracker/view/widget/example_chart_card.dart';
import 'package:investment_tracker/view/widget/investment_card.dart';
import 'package:investment_tracker/view/widget/investment_chart_card.dart';
import 'package:investment_tracker/view/widget/tip_card.dart';
import 'package:investment_tracker/view_model/investment_view_model.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class InvestmentOverview extends StatefulWidget {
  @override _InvestmentOverviewState createState() => _InvestmentOverviewState();
}

class _InvestmentOverviewState extends State<InvestmentOverview> {
  double previousUpdate = 0;

  @override
  Widget build(BuildContext context) {
    final investmentViewModel = Provider.of<InvestmentViewModel>(context);

    return Scaffold(
        body: getInvestmentWidget(context, investmentViewModel.response),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amberAccent,
          child: Icon(Icons.add),
          onPressed: () => {
            showBottomSheet()
          },
        )
    );
  }

  Widget getInvestmentWidget(BuildContext context, InvestmentState investmentState) {
    switch (investmentState.status) {
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
        return investmentListBuilder(investmentState.data);
      case Status.INITIAL:
      default:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<InvestmentViewModel>(context, listen: false).getAllInvestments();
      });
      return new Container(
        alignment: AlignmentDirectional.center,
        child: new CircularProgressIndicator(),
      );
    }
  }

  ListView investmentListBuilder(List<Investment> investmentList) {
    if (investmentList != null && investmentList.isNotEmpty) {
      return new ListView.builder(
        itemCount: investmentList.length,
        itemBuilder: (context, index) {
          Investment investment = investmentList[index];
          Investment previousUpdate = investmentList
              .sublist(index + 1, investmentList.length)
              .firstWhereOrNull((item) =>
                  item.isInterimValue && item.timestamp < investment.timestamp);

          if (index == 0) {
            return Column(
              children: [
                InvestmentChartCard(investmentList),
                InvestmentCard(investment, previousUpdate),
              ],
            );
          } else {
            var view = InvestmentCard(investment, previousUpdate);
            return view;
          }
        },
      );
    } else {
      return new ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            if (index == 0 ) {
              return Column(
                  children: [
                    ExampleChartCard(),
                  ]
              );
            } else if (index == 1){
              return TipCard(
                  "Log your first investment!",
                  "Keep track of all your investments by logging them in the app. You can also add investments to a past date."
              );
            } else {
              return TipCard(
                  "Keep your portfolio total up to date!",
                  "Updating your total portfolio regularly will give you the best overview."
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
        return AddInvestmentBottomSheet();
      },
    );
  }

}
