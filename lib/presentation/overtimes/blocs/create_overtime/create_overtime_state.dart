part of 'create_overtime_bloc.dart';

@freezed
class CreateOvertimeState with _$CreateOvertimeState {
  const factory CreateOvertimeState.initial() = _Initial;
  const factory CreateOvertimeState.loading() = _Loading;
  const factory CreateOvertimeState.success(OvertimeResponseModel response) = _Success;
  const factory CreateOvertimeState.error(String message) = _Error;
}
