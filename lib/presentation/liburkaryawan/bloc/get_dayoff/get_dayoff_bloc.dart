import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/datasources/liburkaryawan_remote_datasource.dart';
import '../../../../data/models/response/liburkaryawan_response_model.dart';

part 'get_datoff_event.dart'; 
part 'get_dayoff_state.dart';
part 'get_dayoff_bloc.freezed.dart';

class GetDayoffBloc extends Bloc<GetDayoffEvent, GetDayoffState> {
  final DayOffRemoteDatasource datasource;

  GetDayoffBloc(this.datasource) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getDayOff();
      
      result.fold(
        (error) {
          emit(_Error(error));
        },
        (responseModel) {
          // Memanggil state _Success secara eksplisit dengan melempar responseModel
          emit(_Success(responseModel));
        },
      );
    });
  }
}