import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/payroll_remote_datasource.dart';
import 'payroll_history_event.dart';
import 'payroll_history_state.dart';

class PayrollHistoryBloc
    extends Bloc<PayrollHistoryEvent, PayrollHistoryState> {
  PayrollHistoryBloc() : super(PayrollHistoryInitial()) {
    // Handler untuk memuat list riwayat
    on<FetchPayrollHistory>((event, emit) async {
      emit(PayrollHistoryLoading());
      final result =
          await PayrollRemoteDatasource.instance.getPayrollHistory(event.year);

      result.fold(
        (failureMessage) => emit(PayrollHistoryError(failureMessage)),
        (payrollResponse) {
          if (payrollResponse.data?.history != null) {
            emit(PayrollHistoryLoaded(
                payrollResponse.data!.history!, event.year));
          } else {
            emit(PayrollHistoryError("Riwayat payroll tidak ditemukan"));
          }
        },
      );
    });

    // Handler untuk memuat detail berdasarkan ID yang di-passing
    on<FetchPayrollDetail>((event, emit) async {
      emit(PayrollHistoryLoading());
      final result = await PayrollRemoteDatasource.instance
          .getPayrollDetail(event.idPayrollComponent);

      result.fold(
        (failureMessage) => emit(PayrollHistoryError(failureMessage)),
        (payrollResponse) {
          if (payrollResponse.data != null) {
            emit(PayrollDetailLoaded(payrollResponse.data!));
          } else {
            emit(PayrollHistoryError("Detail payroll tidak ditemukan"));
          }
        },
      );
    });
  }
}
