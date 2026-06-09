import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/overtime_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';

part 'get_overtimes_bloc.freezed.dart';
part 'get_overtimes_event.dart';
part 'get_overtimes_state.dart';

class GetOvertimesBloc extends Bloc<GetOvertimesEvent, GetOvertimesState> {
  final OvertimeRemoteDatasource datasource;
  GetOvertimesBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetOvertimes>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getOvertimes(month: event.month);
      result.fold(
        (l) => emit(_Error(l)),
        (r) {
          if (r.data == null || r.data!.isEmpty) {
            emit(const _Empty());
          } else {
            emit(_Loaded(r.data!));
          }
        },
      );
    });
  }
}
