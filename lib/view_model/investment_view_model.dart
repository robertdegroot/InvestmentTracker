import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:investment_tracker/model/database_helper.dart';
import 'package:investment_tracker/model/database_response.dart';
import 'package:investment_tracker/model/investment.dart';

class InvestmentViewModel with ChangeNotifier {

  final dbHelper = DatabaseHelper.instance;

  DatabaseResponse _databaseResponse = DatabaseResponse.initial('Empty data');
  List<Map<String, dynamic>> _investments;

  List<Map<String, dynamic>> get investments {
    return _investments;
  }

  DatabaseResponse get response {
    return _databaseResponse;
  }

  Future<void> getAllInvestments() async {
    _databaseResponse = DatabaseResponse.loading("Loading all investments");
    print("LOADING");
    notifyListeners();

    // print("Artificial loading time for debugging");
    // await Future.delayed(const Duration(milliseconds: 1000));

    try {
      _investments = await dbHelper.queryAllRows();
      _databaseResponse = DatabaseResponse.completed(_investments);
      print("COMPLETED LOADING");
    } catch(exception) {
      _databaseResponse = DatabaseResponse.error(exception);
      print("ERROR LOADING");
    }

    notifyListeners();
  }

  Future<void> deleteInvestment(Investment investment) async {
    _databaseResponse = DatabaseResponse.loading("Deleting investment");
    print("DELETING");
    notifyListeners();

    try {
      await dbHelper.delete(investment.id);
      _databaseResponse = DatabaseResponse.completed(_investments);
      print("COMPLETED DELETING");
    } catch(exception) {
      _databaseResponse = DatabaseResponse.error(exception);
      print("ERROR DELETING");
    }

    //TODO adjust on the fly
    getAllInvestments();
    notifyListeners();
  }

  Future<void> insertInvestment(Investment investment) async {
    _databaseResponse = DatabaseResponse.loading("Deleting investment");
    print("INSERTING");
    notifyListeners();

    try {
      await dbHelper.insert(investment.toMap());
      _databaseResponse = DatabaseResponse.completed(_investments);
      print("COMPLETED INSERTING");
    } catch(exception) {
      _databaseResponse = DatabaseResponse.error(exception);
      print("ERROR INSERTING");
    }

    //TODO adjust on the fly
    getAllInvestments();
    notifyListeners();
  }

}