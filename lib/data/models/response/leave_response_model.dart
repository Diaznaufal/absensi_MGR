import 'dart:convert';

class LeaveResponseModel {
  final String? message;
  final List<Leave>? data;

  LeaveResponseModel({
    this.message,
    this.data,
  });

  factory LeaveResponseModel.fromJson(String str) =>
      LeaveResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveResponseModel.fromMap(Map<String, dynamic> json) =>
      LeaveResponseModel(
        message: json['message'],
        data: json['data'] == null
            ? []
            : List<Leave>.from(
                json['data']!.map((x) => Leave.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'data':
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class Leave {
  final int? id;
  final int? employeeId;
  final int? leaveTypeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? totalDays;
  final String? reason;
  final String? attachmentUrl;
  final String? status;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LeaveType? leaveType;
  final Approver? approver;

  Leave({
    this.id,
    this.employeeId,
    this.leaveTypeId,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.reason,
    this.attachmentUrl,
    this.status,
    this.approvedBy,
    this.approvedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.leaveType,
    this.approver,
  });

  factory Leave.fromJson(String str) => Leave.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Leave.fromMap(Map<String, dynamic> json) => Leave(
        id: json['id'],
        employeeId: json['employee_id'],
        leaveTypeId: json['leave_type_id'],
        startDate: json['start_date'] == null
            ? null
            : DateTime.parse(json['start_date']),
        endDate:
            json['end_date'] == null ? null : DateTime.parse(json['end_date']),
        totalDays: json['total_days'],
        reason: json['reason'],
        attachmentUrl: json['attachment_url'],
        status: json['status'],
        approvedBy: json['approved_by'],
        approvedAt: json['approved_at'] == null
            ? null
            : DateTime.parse(json['approved_at']),
        notes: json['notes'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        leaveType: json['leave_type'] == null
            ? null
            : LeaveType.fromMap(json['leave_type']),
        approver: json['approver'] == null
            ? null
            : Approver.fromMap(json['approver']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'employee_id': employeeId,
        'leave_type_id': leaveTypeId,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'total_days': totalDays,
        'reason': reason,
        'attachment_url': attachmentUrl,
        'status': status,
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'leave_type': leaveType?.toMap(),
        'approver': approver?.toMap(),
      };
}

class LeaveType {
  final int? id;
  final String? name;
  final int? quotaDays;
  final bool? isPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveType({
    this.id,
    this.name,
    this.quotaDays,
    this.isPaid,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveType.fromJson(String str) => LeaveType.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveType.fromMap(Map<String, dynamic> json) => LeaveType(
        id: json['id'],
        name: json['name'],
        quotaDays: json['quota_days'],
        isPaid: json['is_paid'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quota_days': quotaDays,
        'is_paid': isPaid,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class Approver {
  final int? id;
  final String? name;
  final String? email;
  final dynamic emailVerifiedAt;
  final dynamic twoFactorSecret;
  final dynamic twoFactorRecoveryCodes;
  final dynamic twoFactorConfirmedAt;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? phone;
  final String? role;
  final String? position;
  final String? department;
  final int? jabatanId;
  final int? departemenId;
  final int? shiftKerjaId;
  final dynamic faceEmbedding;
  final String? imageUrl;

  Approver({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.twoFactorSecret,
    this.twoFactorRecoveryCodes,
    this.twoFactorConfirmedAt,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.role,
    this.position,
    this.department,
    this.jabatanId,
    this.departemenId,
    this.shiftKerjaId,
    this.faceEmbedding,
    this.imageUrl,
  });

  factory Approver.fromJson(String str) => Approver.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Approver.fromMap(Map<String, dynamic> json) => Approver(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        emailVerifiedAt: json['email_verified_at'],
        twoFactorSecret: json['two_factor_secret'],
        twoFactorRecoveryCodes: json['two_factor_recovery_codes'],
        twoFactorConfirmedAt: json['two_factor_confirmed_at'],
        fcmToken: json['fcm_token'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        phone: json['phone'],
        role: json['role'],
        position: json['position'],
        department: json['department'],
        jabatanId: json['jabatan_id'],
        departemenId: json['departemen_id'],
        shiftKerjaId: json['shift_kerja_id'],
        faceEmbedding: json['face_embedding'],
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'two_factor_secret': twoFactorSecret,
        'two_factor_recovery_codes': twoFactorRecoveryCodes,
        'two_factor_confirmed_at': twoFactorConfirmedAt,
        'fcm_token': fcmToken,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'phone': phone,
        'role': role,
        'position': position,
        'department': department,
        'jabatan_id': jabatanId,
        'departemen_id': departemenId,
        'shift_kerja_id': shiftKerjaId,
        'face_embedding': faceEmbedding,
        'image_url': imageUrl,
      };
}
