part of 'start_overtime_bloc.dart';

@freezed
class StartOvertimeEvent with _$StartOvertimeEvent {
  const factory StartOvertimeEvent.started() = _Started;
  const factory StartOvertimeEvent.startOvertime({
    String? notes,
    String? reason,
    XFile? startDocumentPath,
  }) = _StartOvertime;
}
