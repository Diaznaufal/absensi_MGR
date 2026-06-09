import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/request/create_leave_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/leave_response_model.dart';

part 'create_leave_bloc.freezed.dart';
part 'create_leave_event.dart';
part 'create_leave_state.dart';

class CreateLeaveBloc extends Bloc<CreateLeaveEvent, CreateLeaveState> {
  final LeaveRemoteDatasource datasource;
  CreateLeaveBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_CreateLeave>((event, emit) async {
      emit(const _Loading());
      final request = CreateLeaveRequestModel(
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
        attachment: event.attachment,
      );
      final result = await datasource.createLeave(request);
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)),
      );
    });
  }
}
