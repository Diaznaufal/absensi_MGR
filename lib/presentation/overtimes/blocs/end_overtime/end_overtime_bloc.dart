import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/overtime_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';

part 'end_overtime_bloc.freezed.dart';
part 'end_overtime_event.dart';
part 'end_overtime_state.dart';

class EndOvertimeBloc extends Bloc<EndOvertimeEvent, EndOvertimeState> {
  final OvertimeRemoteDatasource datasource;
  EndOvertimeBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_EndOvertime>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.endOvertime(
        id: event.id,
        reason: event.reason,
      );
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(const _Success()),
      );
    });
  }
}
