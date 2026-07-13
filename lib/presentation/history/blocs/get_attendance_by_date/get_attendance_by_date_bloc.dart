import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';

part 'get_attendance_by_date_bloc.freezed.dart';
part 'get_attendance_by_date_event.dart';
part 'get_attendance_by_date_state.dart';

class GetAttendanceByDateBloc
    extends Bloc<GetAttendanceByDateEvent, GetAttendanceByDateState> {
  final AttendanceRemoteDatasource datasource;
  GetAttendanceByDateBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetAttendanceByDate>((event, emit) async {
  emit(const _Loading());
  
  // GANTI: Panggil getScheduleToday() untuk mengambil jadwal aktif hari ini
  final result = await datasource.getScheduleToday();
  
  result.fold(
    (message) => emit(_Error(message)),
    (scheduleMap) {
      if (scheduleMap.isEmpty) {
        emit(const _Empty());
      } else {
        // Karena responsenya berbentuk Map (bukan List lagi seperti versi lama),
        // sesuaikan state Loaded kamu untuk menerima objek Map tersebut.
        emit(_Loaded(scheduleMap));
      }
    },
  );
});
  }
}
