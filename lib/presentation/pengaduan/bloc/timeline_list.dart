import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/timeline_model.dart';
import 'package:flutter/material.dart';

List<TimelineData> buildTimeline(
  PengaduanModel pengaduan,
) {
  return [
    TimelineData(
      title: "Menunggu Verifikasi",
      description: "Laporan Diterima",
      date: pengaduan.tanggalPengaduan,
      color: const Color(0xff3B82F6),
      isActive: true,
    ),
    TimelineData(
      title: "Dalam Proses",
      description: "Sedang Ditinjau Tim Teknis",
      date: pengaduan.tanggalPengaduan,
      color: const Color(0xff3B82F6),
      isActive: pengaduan.status == statusPengaduan.dalamProses ||
          pengaduan.status == statusPengaduan.selesai,
    ),
    TimelineData(
      title: "Selesai",
      description: "Masalah Teratasi dan Kasus Ditutup",
      date: pengaduan.tanggalPengaduan,
      color: const Color(0xff3B82F6),
      isActive: pengaduan.status == statusPengaduan.selesai,
    ),
  ];
}
