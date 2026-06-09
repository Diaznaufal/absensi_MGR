import 'dart:convert';
import 'dart:io';

class CreateLeaveRequestModel {
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String? reason;
  final File? attachment;

  CreateLeaveRequestModel({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.attachment,
  });

  factory CreateLeaveRequestModel.fromJson(String str) =>
      CreateLeaveRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreateLeaveRequestModel.fromMap(Map<String, dynamic> json) =>
      CreateLeaveRequestModel(
        leaveTypeId: json['leave_type_id'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        reason: json['reason'],
      );

  Map<String, dynamic> toMap() => {
        'leave_type_id': leaveTypeId.toString(),
        'start_date': startDate,
        'end_date': endDate,
        if (reason != null && reason!.isNotEmpty) 'reason': reason,
      };
}
