import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_absensi_app/data/datasources/overtime_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';

part 'start_overtime_bloc.freezed.dart';
part 'start_overtime_event.dart';
part 'start_overtime_state.dart';

class StartOvertimeBloc extends Bloc<StartOvertimeEvent, StartOvertimeState> {
  final OvertimeRemoteDatasource datasource;
  StartOvertimeBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_StartOvertime>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.startOvertime(
        notes: event.notes,
        reason: event.reason,
        startDocumentPath: event.startDocumentPath,
      );
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(const _Success()),
      );
    });
  }
}
