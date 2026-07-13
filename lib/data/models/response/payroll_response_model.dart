import 'dart:convert';

class PayrollResponseModel {
  final bool? status;
  final String? message;
  final PayrollData? data;

  PayrollResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory PayrollResponseModel.fromJson(String str) =>
      PayrollResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PayrollResponseModel.fromMap(Map<String, dynamic> json) =>
      PayrollResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : PayrollData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data?.toMap(),
      };
}

class PayrollData {
  // Field untuk endpoint Current / Fallback
  final bool? hasCurrentPayroll;
  final int? month;
  final int? year;
  final String? monthLabel;

  // Field Detail / General Payroll Component Info
  final int? idPayrollComponent;
  final String? codePayroll;
  final String? periodeGajian;
  final String? periodeLabel;
  final String? tanggalGajian;
  final String? tanggalGajianLabel;
  final StatusPembayaran? statusPembayaran;
  
  // Nominal singkat yang ada pada Dashboard/Card Current
  final int? gajiBersih;
  final String? gajiBersihFormatted;

  // Object Lengkap untuk Endpoint Detail
  final Karyawan? karyawan;
  final List<PayrollItem>? penghasilan;
  final List<PayrollItem>? potongan;
  final Ringkasan? ringkasan;
  final Kehadiran? kehadiran;
  final String? description;

  // Field untuk endpoint History
  final int? total;
  final List<PayrollHistoryItem>? history;

  PayrollData({
    this.hasCurrentPayroll,
    this.month,
    this.year,
    this.monthLabel,
    this.idPayrollComponent,
    this.codePayroll,
    this.periodeGajian,
    this.periodeLabel,
    this.tanggalGajian,
    this.tanggalGajianLabel,
    this.statusPembayaran,
    this.gajiBersih,
    this.gajiBersihFormatted,
    this.karyawan,
    this.penghasilan,
    this.potongan,
    this.ringkasan,
    this.kehadiran,
    this.description,
    this.total,
    this.history,
  });

  factory PayrollData.fromJson(String str) => PayrollData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PayrollData.fromMap(Map<String, dynamic> json) => PayrollData(
        hasCurrentPayroll: json["has_current_payroll"],
        month: json["month"],
        year: json["year"],
        monthLabel: json["month_label"],
        idPayrollComponent: json["id_payroll_component"],
        codePayroll: json["code_payroll"],
        periodeGajian: json["periode_gajian"],
        periodeLabel: json["periode_label"],
        tanggalGajian: json["tanggal_gajian"],
        tanggalGajianLabel: json["tanggal_gajian_label"],
        statusPembayaran: json["status_pembayaran"] == null
            ? null
            : StatusPembayaran.fromMap(json["status_pembayaran"]),
        gajiBersih: json["gaji_bersih"],
        gajiBersihFormatted: json["gaji_bersih_formatted"],
        karyawan: json["karyawan"] == null ? null : Karyawan.fromMap(json["karyawan"]),
        penghasilan: json["penghasilan"] == null
            ? null
            : List<PayrollItem>.from(
                json["penghasilan"].map((x) => PayrollItem.fromMap(x))),
        potongan: json["potongan"] == null
            ? null
            : List<PayrollItem>.from(
                json["potongan"].map((x) => PayrollItem.fromMap(x))),
        ringkasan: json["ringkasan"] == null ? null : Ringkasan.fromMap(json["ringkasan"]),
        kehadiran: json["kehadiran"] == null ? null : Kehadiran.fromMap(json["kehadiran"]),
        description: json["description"],
        total: json["total"],
        history: json["history"] == null
            ? null
            : List<PayrollHistoryItem>.from(
                json["history"].map((x) => PayrollHistoryItem.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "has_current_payroll": hasCurrentPayroll,
        "month": month,
        "year": year,
        "month_label": monthLabel,
        "id_payroll_component": idPayrollComponent,
        "code_payroll": codePayroll,
        "periode_gajian": periodeGajian,
        "periode_label": periodeLabel,
        "tanggal_gajian": tanggalGajian,
        "tanggal_gajian_label": tanggalGajianLabel,
        "status_pembayaran": statusPembayaran?.toMap(),
        "gaji_bersih": gajiBersih,
        "gaji_bersih_formatted": gajiBersihFormatted,
        "karyawan": karyawan?.toMap(),
        "penghasilan": penghasilan == null
            ? null
            : List<dynamic>.from(penghasilan!.map((x) => x.toMap())),
        "potongan": potongan == null
            ? null
            : List<dynamic>.from(potongan!.map((x) => x.toMap())),
        "ringkasan": ringkasan?.toMap(),
        "kehadiran": kehadiran?.toMap(),
        "description": description,
        "total": total,
        "history": history == null
            ? null
            : List<dynamic>.from(history!.map((x) => x.toMap())),
      };
}

class StatusPembayaran {
  final String? kode;
  final String? label;

  StatusPembayaran({
    this.kode,
    this.label,
  });

  factory StatusPembayaran.fromMap(Map<String, dynamic> json) => StatusPembayaran(
        kode: json["kode"],
        label: json["label"],
      );

  Map<String, dynamic> toMap() => {
        "kode": kode,
        "label": label,
      };
}

class Karyawan {
  final String? name;
  final String? nip;
  final String? jabatan;
  final String? divisi;
  final String? cabang;

  Karyawan({
    this.name,
    this.nip,
    this.jabatan,
    this.divisi,
    this.cabang,
  });

  factory Karyawan.fromMap(Map<String, dynamic> json) => Karyawan(
        name: json["name"],
        nip: json["nip"],
        jabatan: json["jabatan"],
        divisi: json["divisi"],
        cabang: json["cabang"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "nip": nip,
        "jabatan": jabatan,
        "divisi": divisi,
        "cabang": cabang,
      };
}

class PayrollItem {
  final String? label;
  final int? nilai;
  final String? formatted;

  PayrollItem({
    this.label,
    this.nilai,
    this.formatted,
  });

  factory PayrollItem.fromMap(Map<String, dynamic> json) => PayrollItem(
        label: json["label"],
        nilai: json["nilai"] is double ? (json["nilai"] as double).toInt() : json["nilai"],
        formatted: json["formatted"],
      );

  Map<String, dynamic> toMap() => {
        "label": label,
        "nilai": nilai,
        "formatted": formatted,
      };
}

class Ringkasan {
  final int? totalPenghasilan;
  final String? totalPenghasilanFormatted;
  final int? totalPotongan;
  final String? totalPotonganFormatted;
  final int? gajiBersih;
  final String? gajiBersihFormatted;

  Ringkasan({
    this.totalPenghasilan,
    this.totalPenghasilanFormatted,
    this.totalPotongan,
    this.totalPotonganFormatted,
    this.gajiBersih,
    this.gajiBersihFormatted,
  });

  factory Ringkasan.fromMap(Map<String, dynamic> json) => Ringkasan(
        totalPenghasilan: json["total_penghasilan"],
        totalPenghasilanFormatted: json["total_penghasilan_formatted"],
        totalPotongan: json["total_potongan"],
        totalPotonganFormatted: json["total_potongan_formatted"],
        gajiBersih: json["gaji_bersih"],
        gajiBersihFormatted: json["gaji_bersih_formatted"],
      );

  Map<String, dynamic> toMap() => {
        "total_penghasilan": totalPenghasilan,
        "total_penghasilan_formatted": totalPenghasilanFormatted,
        "total_potongan": totalPotongan,
        "total_potongan_formatted": totalPotonganFormatted,
        "gaji_bersih": gajiBersih,
        "gaji_bersih_formatted": gajiBersihFormatted,
      };
}

class Kehadiran {
  final int? absenHari;
  final int? totalAbsen;
  final int? totalDayoff;

  Kehadiran({
    this.absenHari,
    this.totalAbsen,
    this.totalDayoff,
  });

  factory Kehadiran.fromMap(Map<String, dynamic> json) => Kehadiran(
        absenHari: json["absen_hari"],
        totalAbsen: json["total_absen"],
        totalDayoff: json["total_dayoff"],
      );

  Map<String, dynamic> toMap() => {
        "absen_hari": absenHari,
        "total_absen": totalAbsen,
        "total_dayoff": totalDayoff,
      };
}

class PayrollHistoryItem {
  final int? idPayrollComponent;
  final String? codePayroll;
  final String? periodeGajian;
  final String? monthLabel;
  final int? gajiBersih;
  final String? gajiBersihFormatted;
  final String? tanggalGajianLabel;
  final StatusPembayaran? statusPembayaran;

  PayrollHistoryItem({
    this.idPayrollComponent,
    this.codePayroll,
    this.periodeGajian,
    this.monthLabel,
    this.gajiBersih,
    this.gajiBersihFormatted,
    this.tanggalGajianLabel,
    this.statusPembayaran,
  });

  factory PayrollHistoryItem.fromMap(Map<String, dynamic> json) => PayrollHistoryItem(
        idPayrollComponent: json["id_payroll_component"],
        codePayroll: json["code_payroll"],
        periodeGajian: json["periode_gajian"],
        monthLabel: json["month_label"],
        gajiBersih: json["gaji_bersih"],
        gajiBersihFormatted: json["gaji_bersih_formatted"],
        tanggalGajianLabel: json["tanggal_gajian_label"],
        statusPembayaran: json["status_pembayaran"] == null
            ? null
            : StatusPembayaran.fromMap(json["status_pembayaran"]),
      );

  Map<String, dynamic> toMap() => {
        "id_payroll_component": idPayrollComponent,
        "code_payroll": codePayroll,
        "periode_gajian": periodeGajian,
        "month_label": monthLabel,
        "gaji_bersih": gajiBersih,
        "gaji_bersih_formatted": gajiBersihFormatted,
        "tanggal_gajian_label": tanggalGajianLabel,
        "status_pembayaran": statusPembayaran?.toMap(),
      };
}
