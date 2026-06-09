part of 'end_overtime_bloc.dart';

@freezed
class EndOvertimeState with _$EndOvertimeState {
  const factory EndOvertimeState.initial() = _Initial;
  const factory EndOvertimeState.loading() = _Loading;
  const factory EndOvertimeState.success() = _Success;
  const factory EndOvertimeState.error(String message) = _Error;
}
