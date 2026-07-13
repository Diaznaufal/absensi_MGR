import 'dart:convert';

class DayOffResponseModel {
  final bool? status;
  final String? message;
  final List<DayOffData>? data;

  DayOffResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory DayOffResponseModel.fromJson(String str) =>
      DayOffResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DayOffResponseModel.fromMap(Map<String, dynamic> json) =>
      DayOffResponseModel(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null
            ? []
            : List<DayOffData>.from(
                json['data']!.map((x) => DayOffData.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'message': message,
        'data': data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class DayOffData {
  final String? idDayOff;
  final String? idEmployee;
  final String? tglDayOff;
  final String? inputAt;
  final String? description;
  final String? status;
  final String? statusLabel;

  DayOffData({
    this.idDayOff,
    this.idEmployee,
    this.tglDayOff,
    this.inputAt,
    this.description,
    this.status,
    this.statusLabel,
  });

  factory DayOffData.fromJson(String str) => DayOffData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DayOffData.fromMap(Map<String, dynamic> json) => DayOffData(
        idDayOff: json['id_day_off']?.toString(),
        idEmployee: json['id_employee']?.toString(),
        tglDayOff: json['tgl_day_off'],
        inputAt: json['input_at'],
        description: json['description'],
        status: json['status']?.toString(),
        statusLabel: json['status_label'],
      );

  Map<String, dynamic> toMap() => {
        'id_day_off': idDayOff,
        'id_employee': idEmployee,
        'tgl_day_off': tglDayOff,
        'input_at': inputAt,
        'description': description,
        'status': status,
        'status_label': statusLabel,
      };
}