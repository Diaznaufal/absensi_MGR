import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/leave_balance_response_model.dart';

part 'leave_balance_bloc.freezed.dart';
part 'leave_balance_event.dart';
part 'leave_balance_state.dart';

class LeaveBalanceBloc extends Bloc<LeaveBalanceEvent, LeaveBalanceState> {
  final LeaveRemoteDatasource datasource;
  LeaveBalanceBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetLeaveBalance>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getLeaveBalance(year: event.year);
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)),
      );
    });
  }
}
