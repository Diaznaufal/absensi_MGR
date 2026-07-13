part of 'get_dayoff_bloc.dart';

@freezed
class GetDayoffEvent with _$GetDayoffEvent {
  const factory GetDayoffEvent.started() = _Started;
  const factory GetDayoffEvent.fetch() = _Fetch;
}