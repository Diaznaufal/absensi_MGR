import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';

part 'get_all_attendances_bloc.freezed.dart';
part 'get_all_attendances_event.dart';
part 'get_all_attendances_state.dart';

class GetAllAttendancesBloc
    extends Bloc<GetAllAttendancesEvent, GetAllAttendancesState> {
  final AttendanceRemoteDatasource datasource;
  GetAllAttendancesBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetAllAttendances>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getAllAttendances();
      result.fold(
        (message) => emit(_Error(message)),
        (response) {
          if (response.data == null || response.data!.isEmpty) {
            emit(const _Empty());
          } else {
            emit(_Loaded(response.data!));
          }
        },
      );
    });
  }
}
