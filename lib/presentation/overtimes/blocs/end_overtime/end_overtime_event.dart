part of 'end_overtime_bloc.dart';

@freezed
class EndOvertimeEvent with _$EndOvertimeEvent {
  const factory EndOvertimeEvent.started() = _Started;
  const factory EndOvertimeEvent.endOvertime({
    required int id,
    String? reason,
  }) = _EndOvertime;
}
