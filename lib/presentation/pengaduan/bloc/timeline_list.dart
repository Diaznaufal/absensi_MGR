import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/timeline_model.dart';

List<TimelineData> buildTimeline(
  PengaduanModel pengaduan,
) {
  const blueColor = Color(0xFF3B82F6);

  switch (pengaduan.status) {
    // =========================================
    // STATUS 1 = MENUNGGU
    // =========================================
    case statusPengaduan.menunggu:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          isActive: false,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Selesai',
          description: 'Masalah Teratasi dan Kasus Ditutup',
          isActive: false,
          color: blueColor,
        ),
      ];

    // =========================================
    // STATUS 2 = DALAM PROSES
    // =========================================
    case statusPengaduan.dalamProses:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          isActive: true,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Selesai',
          description: 'Masalah Teratasi dan Kasus Ditutup',
          isActive: false,
          color: blueColor,
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
          color: blueColor,
        ),
        const TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          isActive: true,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Selesai',
          description: 'Masalah Teratasi dan Kasus Ditutup',
          isActive: true,
          color: blueColor,
        ),
      ];

    // =========================================
    // STATUS 4 = TIDAK SELESAI
    //
    // Sesuai alur kamu:
    // Menunggu -> Dalam Proses -> Tidak Selesai
    //
    // "Selesai" tidak ditampilkan sama sekali.
    // =========================================
    case statusPengaduan.tidakselesai:
      return [
        TimelineData(
          title: 'Menunggu Verifikasi',
          description: 'Laporan Diterima',
          date: pengaduan.tanggalPengaduan,
          isActive: true,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Dalam Proses',
          description: 'Sedang Ditinjau Tim Teknis',
          isActive: true,
          color: blueColor,
        ),
        const TimelineData(
          title: 'Tidak Selesai',
          description: 'Pengaduan Tidak Dapat Diselesaikan',
          isActive: true,
          color: Colors.red,
        ),
      ];
  }
}
