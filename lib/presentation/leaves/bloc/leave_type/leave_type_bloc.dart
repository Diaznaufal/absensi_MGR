import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/leave_type_response_model.dart';

part 'leave_type_bloc.freezed.dart';
part 'leave_type_event.dart';
part 'leave_type_state.dart';

class LeaveTypeBloc extends Bloc<LeaveTypeEvent, LeaveTypeState> {
  final LeaveRemoteDatasource datasource;
  LeaveTypeBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetLeaveTypes>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getLeaveTypes();
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)),
      );
    });
  }
}
