import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/datasources/overtime_remote_datasource.dart';
import '../../../../data/models/response/overtime_response_model.dart';

part 'create_overtime_event.dart';
part 'create_overtime_state.dart';
part 'create_overtime_bloc.freezed.dart';

class CreateOvertimeBloc extends Bloc<CreateOvertimeEvent, CreateOvertimeState> {
  final OvertimeRemoteDatasource datasource;

  CreateOvertimeBloc(this.datasource) : super(const _Initial()) {
    on<_Submit>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.createOvertime(
        date: event.date,
        startTime: event.startTime,
        endTime: event.endTime,
        timeSpend: event.timeSpend,
        description: event.description,
      );

      result.fold(
        (error) => emit(_Error(error)),
        (data) => emit(_Success(data)),
      );
    });
  }
}