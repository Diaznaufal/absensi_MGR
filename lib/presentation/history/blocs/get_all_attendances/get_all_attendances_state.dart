part of 'get_all_attendances_bloc.dart';

@freezed
class GetAllAttendancesState with _$GetAllAttendancesState {
  const factory GetAllAttendancesState.initial() = _Initial;
  const factory GetAllAttendancesState.loading() = _Loading;
  const factory GetAllAttendancesState.loaded(List<Attendance> attendances) = _Loaded;
  const factory GetAllAttendancesState.empty() = _Empty;
  const factory GetAllAttendancesState.error(String message) = _Error;
}
