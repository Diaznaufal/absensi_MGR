import 'dart:convert';

class LeaveBalanceResponseModel {
  final String? message;
  final List<LeaveBalanceData>? data;

  LeaveBalanceResponseModel({
    this.message,
    this.data,
  });

  factory LeaveBalanceResponseModel.fromJson(String str) =>
      LeaveBalanceResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveBalanceResponseModel.fromMap(Map<String, dynamic> json) =>
      LeaveBalanceResponseModel(
        message: json['message'],
        data: json['data'] == null
            ? []
            : List<LeaveBalanceData>.from(
                json['data']!.map((x) => LeaveBalanceData.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'data': data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class LeaveBalanceData {
  final int? id;
  final int? employeeId;
  final int? leaveTypeId;
  final int? year;
  final int? quotaDays;
  final int? usedDays;
  final int? remainingDays;
  final int? carryOverDays;
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LeaveTypeInBalance? leaveType;

  LeaveBalanceData({
    this.id,
    this.employeeId,
    this.leaveTypeId,
    this.year,
    this.quotaDays,
    this.usedDays,
    this.remainingDays,
    this.carryOverDays,
    this.lastUpdated,
    this.createdAt,
    this.updatedAt,
    this.leaveType,
  });

  factory LeaveBalanceData.fromJson(String str) =>
      LeaveBalanceData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveBalanceData.fromMap(Map<String, dynamic> json) =>
      LeaveBalanceData(
        id: json['id'],
        employeeId: json['employee_id'],
        leaveTypeId: json['leave_type_id'],
        year: json['year'],
        quotaDays: json['quota_days'],
        usedDays: json['used_days'],
        remainingDays: json['remaining_days'],
        carryOverDays: json['carry_over_days'],
        lastUpdated: json['last_updated'] == null
            ? null
            : DateTime.parse(json['last_updated']),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        leaveType: json['leave_type'] == null
            ? null
            : LeaveTypeInBalance.fromMap(json['leave_type']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'employee_id': employeeId,
        'leave_type_id': leaveTypeId,
        'year': year,
        'quota_days': quotaDays,
        'used_days': usedDays,
        'remaining_days': remainingDays,
        'carry_over_days': carryOverDays,
        'last_updated': lastUpdated?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'leave_type': leaveType?.toMap(),
      };
}

class LeaveTypeInBalance {
  final int? id;
  final String? name;
  final int? quotaDays;
  final bool? isPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveTypeInBalance({
    this.id,
    this.name,
    this.quotaDays,
    this.isPaid,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveTypeInBalance.fromJson(String str) =>
      LeaveTypeInBalance.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveTypeInBalance.fromMap(Map<String, dynamic> json) =>
      LeaveTypeInBalance(
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
