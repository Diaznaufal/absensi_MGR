import '../../../../data/models/response/payroll_response_model.dart';

abstract class DashboardPayrollState {}

class DashboardPayrollInitial extends DashboardPayrollState {}

class DashboardPayrollLoading extends DashboardPayrollState {}

class DashboardPayrollLoaded extends DashboardPayrollState {
  final PayrollData data;
  DashboardPayrollLoaded(this.data);
}

class DashboardPayrollError extends DashboardPayrollState {
  final String message;
  DashboardPayrollError(this.message);
}
