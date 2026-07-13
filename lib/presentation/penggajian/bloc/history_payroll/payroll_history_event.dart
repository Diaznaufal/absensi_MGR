abstract class PayrollHistoryEvent {}

class FetchPayrollHistory extends PayrollHistoryEvent {
  final int year;
  FetchPayrollHistory(this.year);
}

class FetchPayrollDetail extends PayrollHistoryEvent {
  final int idPayrollComponent;
  FetchPayrollDetail(this.idPayrollComponent);
}