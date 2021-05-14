import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:investment_tracker/model/investment/investment_database_helper.dart';
import 'package:investment_tracker/model/investment/investment_state.dart';
import 'package:investment_tracker/model/investment/investment.dart';

class InvestmentViewModel with ChangeNotifier {

  final dbHelper = InvestmentDatabaseHelper.instance;

  InvestmentState _investmentState = InvestmentState.initial('Initial investment state');

  List<Investment> _investments;

  List<Investment> get investments {
    return _investments;
  }

  InvestmentState get response {
    return _investmentState;
  }

  Future<void> getAllInvestments() async {
    _investmentState = InvestmentState.loading("Loading all investments");
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

      if (_investments.isNotEmpty) {
        _investmentState = InvestmentState.completed("Loaded investment", _investments);
      } else {
        _investmentState = InvestmentState.empty("No investments found", _investments);
      }
    } catch(exception) {
      _investmentState = InvestmentState.error(exception);
    }

    notifyListeners();
  }

  Future<void> deleteInvestment(Investment investment) async {
    _investmentState = InvestmentState.loading("Deleting investment");
    notifyListeners();

    try {
      await dbHelper.delete(investment.id);

      _investments.remove(investment);

      if (_investments.isNotEmpty) {
        _investmentState = InvestmentState.completed("Deleted investment", _investments);
      } else {
        _investmentState = InvestmentState.empty("No investments found", _investments);
      }
    } catch(exception) {
      _investmentState = InvestmentState.error(exception);
    }

    notifyListeners();
  }

  Future<void> insertInvestment(Investment investment) async {
    _investmentState = InvestmentState.loading("Inserting investment");
    notifyListeners();

    try {
      await dbHelper.insert(investment.toMap());

      _investments.add(investment);

      _investments.sort((a, b) {
        int compare = b.timestamp.compareTo(a.timestamp);

        if (compare == 0) {
          return b.isInterimValue ? 1 : 0;
        } else {
          return compare;
        }
      });

      _investmentState = InvestmentState.completed("Inserted investment", investments);
    } catch(exception) {
      _investmentState = InvestmentState.error(exception);
    }

    notifyListeners();
  }

}