import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/timeline_model.dart';

List<TimelineData> buildTimeline(PengaduanModel pengaduan) {
  const Color colorMenunggu = Color(0xFFF59E0B);
  const Color colorProses = Color(0xFF3B82F6);
  const Color colorSelesai = Color(0xFF009236);
  const Color colorTidakSelesai = Color(0xFFF10000);

  switch (pengaduan.status) {
    // =========================================
    // STATUS 1 = MENUNGGU DIPROSES
    // =========================================
    case statusPengaduan.menunggu:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorMenunggu,
        ),
        const TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          isActive: false,
          color: colorProses,
        ),
        const TimelineData(
          title: 'Selesai',
          description: 'Masalah Teratasi dan Kasus Ditutup',
          isActive: false,
          color: colorSelesai,
        ),
      ];

    // =========================================
    // STATUS 2 = SEDANG DIPROSES
    // =========================================
    case statusPengaduan.dalamProses:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorMenunggu,
        ),
        TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorProses,
        ),
        const TimelineData(
          title: 'Selesai',
          description: 'Masalah Teratasi dan Kasus Ditutup',
          isActive: false,
          color: colorSelesai,
        ),
      ];

    // =========================================
    // STATUS 3 = SELESAI
    // =========================================
    case statusPengaduan.selesai:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorMenunggu,
        ),
        TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorProses,
        ),
        TimelineData(
          title: 'Selesai',
          description: 'Masalah Teratasi dan Kasus Ditutup',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorSelesai,
        ),
      ];

    // =========================================
    // STATUS 4 = TIDAK SELESAI
    // =========================================
    case statusPengaduan.tidakselesai:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorMenunggu,
        ),
        TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorProses,
        ),
        TimelineData(
          title: 'Tidak Selesai',
          description: 'Pengaduan Tidak Dapat Diselesaikan',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: colorTidakSelesai,
        ),
      ];
  }
}
