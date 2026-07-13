import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';

part 'is_checkedin_bloc.freezed.dart';
part 'is_checkedin_event.dart';
part 'is_checkedin_state.dart';

class IsCheckedinBloc extends Bloc<IsCheckedinEvent, IsCheckedinState> {
  final AttendanceRemoteDatasource datasource;
  
  IsCheckedinBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_IsCheckedIn>((event, emit) async {
      emit(const _Loading());
      
      // Mengubah pemanggilan ke API tunggal /absence/today
      final result = await datasource.getAbsenceToday();
      
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)), // Langsung mem-passing Map data ke State Success
      );
    });
  }
}