part of 'get_overtimes_bloc.dart';

@freezed
class GetOvertimesState with _$GetOvertimesState {
  const factory GetOvertimesState.initial() = _Initial;
  const factory GetOvertimesState.loading() = _Loading;
  const factory GetOvertimesState.loaded(List<Overtime> overtimes) = _Loaded;
  const factory GetOvertimesState.empty() = _Empty;
  const factory GetOvertimesState.error(String message) = _Error;
}
