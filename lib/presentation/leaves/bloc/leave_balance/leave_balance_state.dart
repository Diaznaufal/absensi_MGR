part of 'leave_balance_bloc.dart';

@freezed
class LeaveBalanceState with _$LeaveBalanceState {
  const factory LeaveBalanceState.initial() = _Initial;
  const factory LeaveBalanceState.loading() = _Loading;
  const factory LeaveBalanceState.success(LeaveBalanceResponseModel response) = _Success;
  const factory LeaveBalanceState.error(String message) = _Error;
}
