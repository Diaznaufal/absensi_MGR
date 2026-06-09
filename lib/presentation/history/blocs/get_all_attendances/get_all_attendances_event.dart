part of 'get_all_attendances_bloc.dart';

@freezed
class GetAllAttendancesEvent with _$GetAllAttendancesEvent {
  const factory GetAllAttendancesEvent.started() = _Started;
  const factory GetAllAttendancesEvent.getAllAttendances() = _GetAllAttendances;
}
