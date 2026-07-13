part of 'create_leave_bloc.dart';

@freezed
class CreateLeaveEvent with _$CreateLeaveEvent {
  const factory CreateLeaveEvent.started() = _Started;
  const factory CreateLeaveEvent.createLeave({
    required int leaveTypeId,
    required String startDate,
     String? endDate,
    required String reason,
    required String inputAt,
    required int totalDays,
    required int type,
    File? attachment,
  }) = _CreateLeave;
}
