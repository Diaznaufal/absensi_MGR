part of 'get_overtime_status_bloc.dart';

@freezed
class GetOvertimeStatusEvent with _$GetOvertimeStatusEvent {
  const factory GetOvertimeStatusEvent.started() = _Started;
  const factory GetOvertimeStatusEvent.getOvertimeStatus() =
      _GetOvertimeStatus;
}
