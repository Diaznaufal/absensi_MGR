part of 'get_overtimes_bloc.dart';

@freezed
class GetOvertimesEvent with _$GetOvertimesEvent {
  const factory GetOvertimesEvent.started() = _Started;
  const factory GetOvertimesEvent.getOvertimes({String? month}) = _GetOvertimes;
}
