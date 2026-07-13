import 'dart:convert';

class OvertimeResponseModel {
  final bool? status;
  final String? message;
  final List<Overtime>? data;

  OvertimeResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory OvertimeResponseModel.fromJson(String str) =>
      OvertimeResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OvertimeResponseModel.fromMap(Map<String, dynamic> json) =>
      OvertimeResponseModel(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null
            ? []
            : List<Overtime>.from(
                json['data']!.map((x) => Overtime.fromMap(x)),
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

class Overtime {
  final String? idOvertime;
  final String? idEmployee;
  final String? tanggal;
  final String? inputAt;
  final String? timeSpend;
  final String? start;
  final String? end;
  final String? description;
  final String? status;
  final String? pay;
  final String? statusLabel;

  Overtime({
    this.idOvertime,
    this.idEmployee,
    this.tanggal,
    this.inputAt,
    this.timeSpend,
    this.start,
    this.end,
    this.description,
    this.status,
    this.pay,
    this.statusLabel,
  });

  factory Overtime.fromJson(String str) => Overtime.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Overtime.fromMap(Map<String, dynamic> json) => Overtime(
      idOvertime: json['id_overtime']?.toString(),
      idEmployee: json['id_employee']?.toString(),
      tanggal: json['tanggal'],
      inputAt: json['input_at'],
      timeSpend: json['time_spend']?.toString(),
      start: json['start'],
      end: json['end'],
      description: json['description'],
      status: json['status']?.toString(),
      pay: json['pay']?.toString(),
      statusLabel: json['status_label']);

  Map<String, dynamic> toMap() => {
        'id_overtime': idOvertime,
        'id_employee': idEmployee,
        'tanggal': tanggal,
        'input_at': inputAt,
        'time_spend': timeSpend,
        'start': start,
        'end': end,
        'description': description,
        'status': status,
        'pay': pay,
        'status_label': statusLabel,
      };
}

class OvertimeSingleResponseModel {
  final bool? status;
  final String? message;
  final Overtime? data;

  OvertimeSingleResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory OvertimeSingleResponseModel.fromJson(String str) =>
      OvertimeSingleResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OvertimeSingleResponseModel.fromMap(Map<String, dynamic> json) =>
      OvertimeSingleResponseModel(
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