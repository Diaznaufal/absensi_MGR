part of 'add_dayoff_bloc.dart';

@freezed
class AddDayoffState with _$AddDayoffState {
  const factory AddDayoffState.initial() = _Initial;
  const factory AddDayoffState.loading() = _Loading;
  // Pastikan di sini tipenya DayOffSingleResponseModel
  const factory AddDayoffState.success(DayOffResponseModel data) = _Success;
  const factory AddDayoffState.error(String message) = _Error;
}