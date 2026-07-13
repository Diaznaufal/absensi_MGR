import 'dart:convert';

class AttendanceResponseModel {
  final String? message;
  final List<AttendanceSchedule>? data;

  AttendanceResponseModel({
    this.message,
    this.data,
  });

  factory AttendanceResponseModel.fromJson(String str) =>
      AttendanceResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AttendanceResponseModel.fromMap(Map<String, dynamic> json) =>
      AttendanceResponseModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<AttendanceSchedule>.from(
                json["data"]!.map((x) => AttendanceSchedule.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class AttendanceSchedule {
  final String? idSchedule;
  final String? idEmployee;
  final String? idAttendance;
  final DateTime? waktu;
  final String? jamMasuk;
  final String? jamKeluar;
  final String? tanggalMasuk;
  final int? status;
  final String? statusLabel;
  final String? nameWorkshift;
  final String? clockIn;
  final String? clockOut;
  final dynamic
      timeManagement; // 💡 Menambahkan tracking manajemen waktu keterlambatan

  AttendanceSchedule({
    this.idSchedule,
    this.idEmployee,
    this.idAttendance,
    this.waktu,
    this.jamMasuk,
    this.jamKeluar,
    this.tanggalMasuk,
    this.status,
    this.statusLabel,
    this.nameWorkshift,
    this.clockIn,
    this.clockOut,
    this.timeManagement, // 💡 Register constructor
  });

  factory AttendanceSchedule.fromJson(String str) =>
      AttendanceSchedule.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AttendanceSchedule.fromMap(Map<String, dynamic> json) =>
      AttendanceSchedule(
        idSchedule: json["id_schedule"]?.toString(),
        idEmployee: json["id_employee"]?.toString(),
        idAttendance: json["id_attendance"]?.toString(),
        waktu: json["waktu"] == null ? null : DateTime.parse(json['waktu']),
        jamMasuk: json["jam_masuk"],
        jamKeluar: json["jam_keluar"],
        tanggalMasuk: json["tanggal_masuk"],
        // 💡 SINKRONISASI 1: Memperbaiki kesalahan fatal pencarian string key 'statu' menjadi 'status'
        status: json["status"] != null
            ? int.tryParse(json['status'].toString())
            : null,
        statusLabel: json["status_label"],
        nameWorkshift: json["name_workshift"],
        clockIn: json["clock_in"],
        clockOut: json["clock_out"],
        timeManagement: json[
            "time_management"], // 💡 SINKRONISASI 2: Map key dari database server
      );

  Map<String, dynamic> toMap() => {
        "id_schedule": idSchedule,
        "id_employee": idEmployee,
        "id_attendance": idAttendance,
        "waktu": waktu == null
            ? null
            : "${waktu!.year.toString().padLeft(4, '0')}-${waktu!.month.toString().padLeft(2, '0')}-${waktu!.day.toString().padLeft(2, '0')}",
        "jam_masuk": jamMasuk,
        "jam_keluar": jamKeluar,
        "tanggal_masuk": tanggalMasuk,
        "status": status,
        "status_label": statusLabel,
        "name_workshift": nameWorkshift,
        "clock_in": clockIn,
        "clock_out": clockOut,
        "time_management": timeManagement, // 💡 Output balik enkripsi data map
      };
}
