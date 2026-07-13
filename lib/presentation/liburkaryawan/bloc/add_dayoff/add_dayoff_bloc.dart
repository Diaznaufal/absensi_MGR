import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/datasources/liburkaryawan_remote_datasource.dart';
import '../../../../data/models/response/liburkaryawan_response_model.dart';

part 'add_dayoff_event.dart';
part 'add_dayoff_state.dart';
part 'add_dayoff_bloc.freezed.dart'; // Pastikan nama file .freezed sesuai gambar kamu

class AddDayoffBloc extends Bloc<AddDayoffEvent, AddDayoffState> {
  final DayOffRemoteDatasource datasource;

  AddDayoffBloc(this.datasource) : super(const _Initial()) {
    on<_AddDayoff>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.addDayOff(
        inputAt: event.inputAt,
        tglDayOff: event.tglDayOff,
        description: event.description,
      );
      result.fold(
        (error) => emit(_Error(error)),
        (data) => emit(_Success(data)),
      );
    });
  }
}