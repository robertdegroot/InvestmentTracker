class InvestmentState<T> {
  Status status;
  T data;
  String message;

  InvestmentState.initial(this.message) : status = Status.INITIAL;

  InvestmentState.loading(this.message) : status = Status.LOADING;

  InvestmentState.completed(this.data) : status = Status.COMPLETED;

  InvestmentState.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { INITIAL, LOADING, COMPLETED, ERROR }