part of 'leave_balance_bloc.dart';

@freezed
class LeaveBalanceEvent with _$LeaveBalanceEvent {
  const factory LeaveBalanceEvent.started() = _Started;
  const factory LeaveBalanceEvent.getLeaveBalance({String? year}) = _GetLeaveBalance;
}
