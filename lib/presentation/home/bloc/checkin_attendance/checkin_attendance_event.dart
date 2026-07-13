part of 'checkin_attendance_bloc.dart';

@freezed
class CheckinAttendanceEvent with _$CheckinAttendanceEvent {
  const factory CheckinAttendanceEvent.started() = _Started;
  const factory CheckinAttendanceEvent.checkin({
    required double latitute,
    required double longitude,
    required String imagePath,
    required String idSchedule,
  }) = _Checkin;
}
