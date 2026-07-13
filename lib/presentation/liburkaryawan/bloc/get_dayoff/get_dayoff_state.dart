part of 'get_dayoff_bloc.dart';

@freezed
class GetDayoffState with _$GetDayoffState {
  const factory GetDayoffState.initial() = _Initial;
  const factory GetDayoffState.loading() = _Loading;
  const factory GetDayoffState.success(DayOffResponseModel data) = _Success;
  const factory GetDayoffState.error(String message) = _Error;
}
