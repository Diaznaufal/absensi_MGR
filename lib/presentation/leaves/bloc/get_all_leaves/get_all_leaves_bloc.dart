import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/leave_response_model.dart';

part 'get_all_leaves_bloc.freezed.dart';
part 'get_all_leaves_event.dart';
part 'get_all_leaves_state.dart';

class GetAllLeavesBloc extends Bloc<GetAllLeavesEvent, GetAllLeavesState> {
  final LeaveRemoteDatasource datasource;
  GetAllLeavesBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GetAllLeaves>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getLeaves(status: event.status);
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)),
      );
    });
  }
}
