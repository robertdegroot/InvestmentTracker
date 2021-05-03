class DatabaseResponse<T> {
  Status status;
  T data;
  String message;

  DatabaseResponse.initial(this.message) : status = Status.INITIAL;

  DatabaseResponse.loading(this.message) : status = Status.LOADING;

  DatabaseResponse.completed(this.data) : status = Status.COMPLETED;

  DatabaseResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { INITIAL, LOADING, COMPLETED, ERROR }