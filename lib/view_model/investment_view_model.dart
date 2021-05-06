import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:investment_tracker/model/database_helper.dart';
import 'package:investment_tracker/model/investment_state.dart';
import 'package:investment_tracker/model/investment.dart';

class InvestmentViewModel with ChangeNotifier {

  final dbHelper = DatabaseHelper.instance;

  InvestmentState _investmentState = InvestmentState.initial('Initial state');

  List<Investment> _investments;

  List<Investment> get investments {
    return _investments;
  }

  InvestmentState get response {
    return _investmentState;
  }

  Future<void> getAllInvestments() async {
    _investmentState = InvestmentState.loading("Loading all investments");
    print("LOADING");
    notifyListeners();

    // print("Artificial loading time for debugging");
    // await Future.delayed(const Duration(milliseconds: 1000));

    try {
      _investments = [];

      var investmentRows = await dbHelper.queryAllRows();

      investmentRows.forEach((element) {
        _investments.add(Investment(
            element['_id'],
            element['timestamp'],
            element['amount'],
            element['description'],
            element['is_interim_value'] == 0
              ? false
              : true,
        ));
      });

      _investmentState = InvestmentState.completed(_investments);

      print("COMPLETED LOADING");
    } catch(exception) {
      _investmentState = InvestmentState.error(exception);
      print("ERROR LOADING");
    }

    notifyListeners();
  }

  Future<void> deleteInvestment(Investment investment) async {
    _investmentState = InvestmentState.loading("Deleting investment");
    print("DELETING ${investment.amount}");
    notifyListeners();

    try {
      await dbHelper.delete(investment.id);

      _investments.remove(investment);
      _investmentState = InvestmentState.completed(_investments);
      print("COMPLETED DELETING");
    } catch(exception) {
      _investmentState = InvestmentState.error(exception);
      print("ERROR DELETING");
    }

    notifyListeners();
  }

  Future<void> insertInvestment(Investment investment) async {
    _investmentState = InvestmentState.loading("Inserting investment");
    print("INSERTING");
    notifyListeners();

    try {
      await dbHelper.insert(investment.toMap());

      _investments.add(investment);
      _investments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _investmentState = InvestmentState.completed(_investments);
      print("COMPLETED INSERTING");
    } catch(exception) {
      _investmentState = InvestmentState.error(exception);
      print("ERROR INSERTING");
    }

    notifyListeners();
  }

}