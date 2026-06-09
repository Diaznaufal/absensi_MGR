import 'dart:convert';

class LeaveTypeResponseModel {
  final String? message;
  final List<LeaveTypeData>? data;

  LeaveTypeResponseModel({
    this.message,
    this.data,
  });

  factory LeaveTypeResponseModel.fromJson(String str) =>
      LeaveTypeResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveTypeResponseModel.fromMap(Map<String, dynamic> json) =>
      LeaveTypeResponseModel(
        message: json['message'],
        data: json['data'] == null
            ? []
            : List<LeaveTypeData>.from(
                json['data']!.map((x) => LeaveTypeData.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'data': data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class LeaveTypeData {
  final int? id;
  final String? name;
  final int? quotaDays;
  final bool? isPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveTypeData({
    this.id,
    this.name,
    this.quotaDays,
    this.isPaid,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveTypeData.fromJson(String str) =>
      LeaveTypeData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LeaveTypeData.fromMap(Map<String, dynamic> json) => LeaveTypeData(
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
