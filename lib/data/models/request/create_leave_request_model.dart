import 'dart:convert';
import 'dart:io';

class CreateLeaveRequestModel {
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String? reason;
  final File? attachment;

  // 🌟 TAMBAHAN: field yang WAJIB divalidasi backend (Leave.php)
  final String inputAt; // tanggal pengajuan dibuat (hari ini)
  final int totalDays; // jumlah hari cuti
  final int type; // 1 = single day, 2 = multi day

  CreateLeaveRequestModel({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.attachment,
    required this.inputAt,
    required this.totalDays,
    required this.type,
  });

  factory CreateLeaveRequestModel.fromJson(String str) =>
      CreateLeaveRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreateLeaveRequestModel.fromMap(Map<String, dynamic> json) =>
      CreateLeaveRequestModel(
        leaveTypeId: json['leave_type_id'],
        startDate: json['start_day'],
        endDate: json['end_day'],
        reason: json['description'],
        inputAt: json['input_at'],
        totalDays: json['total_days'],
        type: json['type'],
      );

  // 🌟 PERBAIKAN: key disamakan dengan yang dibaca Leave.php
  // backend pakai: input_at, total_days, type, start_day, end_day, description
  Map<String, dynamic> toMap() {
    return {
      'input_at': inputAt,
      'total_days': totalDays,
      'type': type,
      'start_day': startDate,

      // kirim end_day selalu
      'end_day': endDate ?? startDate,

      'description': reason ?? '',
    };
  }
}
