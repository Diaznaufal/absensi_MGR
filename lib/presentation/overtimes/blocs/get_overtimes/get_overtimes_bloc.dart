import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/datasources/overtime_remote_datasource.dart';
import '../../../../data/models/response/overtime_response_model.dart';

part 'get_overtimes_event.dart';
part 'get_overtimes_state.dart';
part 'get_overtimes_bloc.freezed.dart';

class GetOvertimesBloc extends Bloc<GetOvertimesEvent, GetOvertimesState> {
  final OvertimeRemoteDatasource datasource;

  GetOvertimesBloc(this.datasource) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getOvertimes(month: event.month);

      result.fold(
        (error) => emit(_Error(error)),
        (data) => emit(_Success(data)),
      );
    });
  }
}