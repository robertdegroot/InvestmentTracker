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

      if (_expenses.isNotEmpty) {
        _expenseState = ExpenseState.completed("Loaded expenses", _expenses);
      } else {
        _expenseState = ExpenseState.empty("No expenses found", _expenses);
      }
    } catch(exception) {
      _expenseState = ExpenseState.error(exception);
    }

    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    _expenseState = ExpenseState.loading("Deleting expense");
    notifyListeners();

    try {
      await dbHelper.delete(expense.id);

      _expenses.remove(expense);

      if (_expenses.isNotEmpty) {
        _expenseState = ExpenseState.completed("Deleted expenses", _expenses);
      } else {
        _expenseState = ExpenseState.empty("No expenses found", _expenses);
      }
    } catch(exception) {
      _expenseState = ExpenseState.error(exception);
    }

    notifyListeners();
  }

  Future<void> insertExpense(Expense expense) async {
    _expenseState = ExpenseState.loading("Inserting expense");
    notifyListeners();

    try {
      await dbHelper.insert(expense.toMap());

      _expenses.add(expense);

      _expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _expenseState = ExpenseState.completed("Inserted expense", _expenses);
    } catch(exception) {
      _expenseState = ExpenseState.error(exception.toString());
    }

    notifyListeners();
  }

}