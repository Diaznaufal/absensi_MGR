import 'package:intl/intl.dart';

enum statusPengaduan { menunggu, dalamProses, selesai, tidakselesai }

class PengaduanModel {
  final String kodePengaduan;
  final String area;
  final String kategori;
  final String? kategoriLainnya;
  final String judul;
  final String isi;
  final List<String> lampiran;
  final statusPengaduan status;
  final DateTime tanggalPengaduan;

  PengaduanModel({
    required this.kodePengaduan,
    required this.area,
    required this.kategori,
    this.kategoriLainnya,
    required this.judul,
    required this.isi,
    required this.lampiran,
    required this.status,
    required this.tanggalPengaduan,
  });

  factory PengaduanModel.fromJson(Map<String, dynamic> json) {
    // 1. Parsing Tanggal (Format API: "21-09-2026" atau ISO)
    DateTime parsedDate;
    final String? rawDate = json['tanggal']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        if (rawDate.contains('-') && rawDate.split('-').first.length == 2) {
          parsedDate = DateFormat('dd-MM-yyyy').parse(rawDate);
        } else {
          parsedDate = DateTime.parse(rawDate);
        }
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    // 2. Parsing Status sesuai urutan opsi dropdown Admin
    statusPengaduan parsedStatus;
    final String rawStatus =
        json['status']?.toString().toLowerCase().trim() ?? '';
    switch (rawStatus) {
      case '1':
      case 'menunggu':
      case 'menunggu diproses':
        parsedStatus = statusPengaduan.menunggu;
        break;
      case '2':
      case 'proses':
      case 'sedang diproses':
        parsedStatus = statusPengaduan.dalamProses;
        break;
      case '3':
      case 'selesai':
        parsedStatus = statusPengaduan.selesai;
        break;
      case '4':
      case 'tidak selesai':
      case 'ditolak':
        parsedStatus = statusPengaduan.tidakselesai;
        break;
      default:
        parsedStatus = statusPengaduan.menunggu;
    }

    // 3. Parsing Lampiran
    List<String> listLampiran = [];
    if (json['lampiran'] != null) {
      if (json['lampiran'] is List) {
        listLampiran =
            List<String>.from(json['lampiran'].map((x) => x.toString()));
      } else if (json['lampiran'].toString().trim().isNotEmpty) {
        listLampiran = [json['lampiran'].toString().trim()];
      }
    }

    return PengaduanModel(
      kodePengaduan:
          json['kode']?.toString() ?? json['kode_pengaduan']?.toString() ?? '-',
      area: json['area']?.toString() ?? '-',
      kategori: json['kategori']?.toString() ?? '-',
      kategoriLainnya: json['kategori_lainnya']?.toString(),
      judul: json['judul']?.toString() ?? '',
      isi: json['pesan']?.toString() ?? json['isi']?.toString() ?? '',
      lampiran: listLampiran,
      status: parsedStatus,
      tanggalPengaduan: parsedDate,
    );
  }
}
