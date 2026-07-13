import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/payroll_remote_datasource.dart';
import 'dashboard_payroll_event.dart';
import 'dashboard_payroll_state.dart';

class DashboardPayrollBloc
    extends Bloc<DashboardPayrollEvent, DashboardPayrollState> {
  DashboardPayrollBloc() : super(DashboardPayrollInitial()) {
    on<FetchCurrentPayroll>((event, emit) async {
      emit(DashboardPayrollLoading());
      final result = await PayrollRemoteDatasource.instance.getCurrentPayroll();

      result.fold(
        (failureMessage) => emit(DashboardPayrollError(failureMessage)),
        (payrollResponse) {
          if (payrollResponse.data != null) {
            emit(DashboardPayrollLoaded(payrollResponse.data!));
          } else {
            emit(DashboardPayrollError("Data payroll tidak ditemukan"));
          }
        },
      );
    });
  }
}
