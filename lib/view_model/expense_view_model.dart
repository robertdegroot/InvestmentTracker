import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:investment_tracker/model/expense/expense.dart';
import 'package:investment_tracker/model/expense/expense_database_helper.dart';
import 'package:investment_tracker/model/expense/expense_state.dart';

class ExpenseViewModel with ChangeNotifier {

  final dbHelper = ExpenseDatabaseHelper.instance;

  ExpenseState _expenseState = ExpenseState.initial('Initial expense state');

  List<Expense> _expenses;

  List<Expense> get expenses {
    return _expenses;
  }

  ExpenseState get response {
    return _expenseState;
  }

  Future<void> getAllExpenses() async {
    _expenseState = ExpenseState.loading("Loading all expenses");
    print("LOADING");
    notifyListeners();

    // print("Artificial loading time for debugging");
    // await Future.delayed(const Duration(milliseconds: 1000));

    try {
      _expenses = [];

      var expenseRows = await dbHelper.queryAllRows();

      expenseRows.forEach((element) {
        _expenses.add(Expense(
          element['_id'],
          element['timestamp'],
          element['amount'],
          element['category'],
          element['note'],
        ));
      });

      _expenseState = ExpenseState.completed(_expenses);

      print("COMPLETED LOADING");
    } catch(exception) {
      _expenseState = ExpenseState.error(exception);
      print("ERROR LOADING");
    }

    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    _expenseState = ExpenseState.loading("Deleting expense");
    print("DELETING ${expense.amount}");
    notifyListeners();

    try {
      await dbHelper.delete(expense.id);

      _expenses.remove(expense);
      _expenseState = ExpenseState.completed(_expenses);
      print("COMPLETED DELETING");
    } catch(exception) {
      _expenseState = ExpenseState.error(exception);
      print("ERROR DELETING");
    }

    notifyListeners();
  }

  Future<void> insertExpense(Expense expense) async {
    _expenseState = ExpenseState.loading("Inserting expense");
    print("INSERTING");
    notifyListeners();

    try {
      await dbHelper.insert(expense.toMap());

      _expenses.add(expense);

      _expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _expenseState = ExpenseState.completed(_expenses);
      print("COMPLETED INSERTING");
    } catch(exception) {
      _expenseState = ExpenseState.error(exception.toString());
      print("ERROR INSERTING: ${exception.toString()}");
    }

    notifyListeners();
  }

}