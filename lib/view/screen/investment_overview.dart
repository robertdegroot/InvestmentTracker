import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investment_tracker/model/investment/investment_state.dart';
import 'package:investment_tracker/model/investment/investment.dart';
import 'package:investment_tracker/view/widget/add_investment_bottom_sheet.dart';
import 'package:investment_tracker/view/widget/example_line_chart_card.dart';
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

  Widget getInvestmentWidget(
      BuildContext context, InvestmentState investmentState) {
    print(investmentState.message);
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
      case Status.EMPTY:
        return investmentEmptyState();
      case Status.INITIAL:
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<InvestmentViewModel>(context, listen: false)
              .getAllInvestments();
        });
        return new Container(
          alignment: AlignmentDirectional.center,
          child: new CircularProgressIndicator(),
        );
    }
  }

  ListView investmentListBuilder(List<Investment> investmentList) {
    return new ListView.builder(
      itemCount: investmentList.length,
      itemBuilder: (context, index) {
        Investment investment = investmentList[index];
        Investment previousUpdate;
        Investment comparisonUpdate;

        if (investment.isInterimValue) {
          previousUpdate = investmentList
              .sublist(index + 1, investmentList.length)
              .firstWhereOrNull((item) =>
                  item.isInterimValue && item.timestamp < investment.timestamp);

          if (previousUpdate != null) {
            double investedInBetween = 0;

            investmentList
                .sublist(index + 1, investmentList.indexOf(previousUpdate))
                .forEach((item) {
              investedInBetween += item.amount;
            });

            comparisonUpdate = Investment(
                -1, -1, previousUpdate.amount + investedInBetween, "", true);
          }
        }

        if (index == 0) {
          return Column(
            children: [
              InvestmentChartCard(investmentList),
              InvestmentCard(investment, comparisonUpdate),
            ],
          );
        } else {
          var view = InvestmentCard(investment, comparisonUpdate);
          return view;
        }
      },
    );
  }

  ListView investmentEmptyState() {
    return new ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          if (index == 0 ) {
            return Column(
                children: [
                  ExampleInvestmentChartCard(),
                ]
            );
          } else if (index == 1){
            return TipCard(
                "Log your first investment!",
                "Keep track of all your investments by logging them in the app. You can also add investments to a past date.",
                BottomSheetType.INVESTMENT
            );
          } else {
            return TipCard(
                "Keep your portfolio total up to date!",
                "Updating your total portfolio regularly will give you the best overview.",
                BottomSheetType.INVESTMENT
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
        return AddInvestmentBottomSheet();
      },
    );
  }

}
