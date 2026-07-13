part of 'leave_type_bloc.dart';

@freezed
class LeaveTypeEvent with _$LeaveTypeEvent {
  const factory LeaveTypeEvent.started() = _Started;
  const factory LeaveTypeEvent.getLeaveTypes() = _GetLeaveTypes;
}
