import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/models/request/checkinout_request_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/checkinout_response_model.dart';

part 'checkout_attendance_bloc.freezed.dart';
part 'checkout_attendance_event.dart';
part 'checkout_attendance_state.dart';

class CheckoutAttendanceBloc
    extends Bloc<CheckoutAttendanceEvent, CheckoutAttendanceState> {
  final AttendanceRemoteDatasource datasource;

  CheckoutAttendanceBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_Checkout>((event, emit) async {
      emit(const _Loading());

      final requestModel = CheckInOutRequestModel(
        latitude: event.latitude.toString(),
        longitude: event.longitude.toString(),
      );

      final result = await datasource.checkoutWithFace(
        data: requestModel,
        imagePath: event.imagePath,
        idSchedule: event.idSchedule,
      );

      result.fold(
        (error) => emit(_Error(error)),
        (response) => emit(_Loaded(response)),
      );
    });
  }
}
