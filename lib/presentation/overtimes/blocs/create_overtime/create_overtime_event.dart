part of 'create_overtime_bloc.dart';

@freezed
class CreateOvertimeEvent with _$CreateOvertimeEvent {
  const factory CreateOvertimeEvent.started() = _Started;
  const factory CreateOvertimeEvent.submit({
    required String date,
    required String startTime,
    required String endTime,
    required String timeSpend,
    required String description,
  }) = _Submit;
}