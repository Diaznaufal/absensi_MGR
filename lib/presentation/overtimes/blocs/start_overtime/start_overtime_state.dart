part of 'start_overtime_bloc.dart';

@freezed
class StartOvertimeState with _$StartOvertimeState {
  const factory StartOvertimeState.initial() = _Initial;
  const factory StartOvertimeState.loading() = _Loading;
  const factory StartOvertimeState.success() = _Success;
  const factory StartOvertimeState.error(String message) = _Error;
}
