part of 'add_dayoff_bloc.dart';

@freezed
class AddDayoffEvent with _$AddDayoffEvent {
  const factory AddDayoffEvent.started() = _Started;
  const factory AddDayoffEvent.addDayOff({
    required String inputAt,
    required String tglDayOff,
    required String description,
  }) = _AddDayoff;
}