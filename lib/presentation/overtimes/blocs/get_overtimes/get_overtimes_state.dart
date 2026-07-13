part of 'get_overtimes_bloc.dart'; 

@freezed
class GetOvertimesState with _$GetOvertimesState {
  const factory GetOvertimesState.initial() = _Initial;
  const factory GetOvertimesState.loading() = _Loading;
  const factory GetOvertimesState.success(OvertimeResponseModel response) = _Success;
  const factory GetOvertimesState.error(String message) = _Error;
}