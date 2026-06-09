part of 'get_overtime_status_bloc.dart';

@freezed
class GetOvertimeStatusState with _$GetOvertimeStatusState {
  const factory GetOvertimeStatusState.initial() = _Initial;
  const factory GetOvertimeStatusState.loading() = _Loading;
  const factory GetOvertimeStatusState.loaded(
      OvertimeStatusResponseModel status) = _Loaded;
  const factory GetOvertimeStatusState.error(String message) = _Error;
}
