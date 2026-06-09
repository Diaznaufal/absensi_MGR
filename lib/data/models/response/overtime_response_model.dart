import 'dart:convert';

class OvertimeResponseModel {
  final String? message;
  final List<Overtime>? data;

  OvertimeResponseModel({
    this.message,
    this.data,
  });

  factory OvertimeResponseModel.fromJson(String str) =>
      OvertimeResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OvertimeResponseModel.fromMap(Map<String, dynamic> json) =>
      OvertimeResponseModel(
        message: json['message'],
        data: json['data'] == null
            ? []
            : List<Overtime>.from(
                json['data']!.map((x) => Overtime.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'data':
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class Overtime {
  final int? id;
  final int? userId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? reason;
  final String? document;
  final String? status;
  final String? notes;
  final DateTime? approvedAt;
  final int? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Overtime({
    this.id,
    this.userId,
    this.date,
    this.startTime,
    this.endTime,
    this.reason,
    this.document,
    this.status,
    this.notes,
    this.approvedAt,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Overtime.fromJson(String str) => Overtime.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Overtime.fromMap(Map<String, dynamic> json) => Overtime(
        id: json['id'],
        userId: json['user_id'],
        date: json['date'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        reason: json['reason'],
        document: json['document'],
        status: json['status'],
        notes: json['notes'],
        approvedAt: json['approved_at'] == null
            ? null
            : DateTime.parse(json['approved_at']),
        approvedBy: json['approved_by'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'reason': reason,
        'document': document,
        'status': status,
        'notes': notes,
        'approved_at': approvedAt?.toIso8601String(),
        'approved_by': approvedBy,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class OvertimeStatusResponseModel {
  final String? status;
  final String? message;
  final Overtime? data;

  OvertimeStatusResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory OvertimeStatusResponseModel.fromJson(String str) =>
      OvertimeStatusResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OvertimeStatusResponseModel.fromMap(Map<String, dynamic> json) =>
      OvertimeStatusResponseModel(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null ? null : Overtime.fromMap(json['data']),
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'message': message,
        'data': data?.toMap(),
      };
}

// Response model for single overtime (start/end overtime)
class OvertimeSingleResponseModel {
  final String? message;
  final Overtime? data;

  OvertimeSingleResponseModel({
    this.message,
    this.data,
  });

  factory OvertimeSingleResponseModel.fromJson(String str) =>
      OvertimeSingleResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OvertimeSingleResponseModel.fromMap(Map<String, dynamic> json) =>
      OvertimeSingleResponseModel(
        message: json['message'],
        data: json['data'] == null ? null : Overtime.fromMap(json['data']),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'data': data?.toMap(),
      };
}
