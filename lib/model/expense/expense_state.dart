class ExpenseState<T> {
  Status status;
  T data;
  String message;

  ExpenseState.initial(this.message) : status = Status.INITIAL;

  ExpenseState.loading(this.message) : status = Status.LOADING;

  ExpenseState.completed(this.message, this.data) : status = Status.COMPLETED;

  ExpenseState.empty(this.message, this.data) : status = Status.EMPTY;

  ExpenseState.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { INITIAL, LOADING, COMPLETED, EMPTY, ERROR }