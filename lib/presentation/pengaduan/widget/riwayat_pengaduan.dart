import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/detail_pengaduan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';

class RiwayatPengaduanCard extends StatelessWidget {
  final String code;
  final DateTime tanggal;
  final statusPengaduan status;
  final PengaduanModel pengaduan;

  const RiwayatPengaduanCard({
    super.key,
    required this.code,
    required this.tanggal,
    required this.status,
    required this.pengaduan,
  });

  String getRiwayatStatus(statusPengaduan status) {
    switch (status) {
      case statusPengaduan.menunggu:
        return "Menunggu Verifikasi";
      case statusPengaduan.dalamProses:
        return "Dalam Proses";
      case statusPengaduan.selesai:
        return "Selesai";
    }
  }

  Color getRiwayatColor(statusPengaduan status) {
    switch (status) {
      case statusPengaduan.menunggu:
        return Color(0xffF59E0B);
      case statusPengaduan.dalamProses:
        return Color(0xff3B82F6);
      case statusPengaduan.selesai:
        return Color(0xff009236);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPengaduan(
              pengaduan: pengaduan,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE7ECF5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF243778),
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy').format(tanggal),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF9AA3BD),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  getRiwayatStatus(status),
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: getRiwayatColor(status)),
                ),
              ],
            ),
            SizedBox(
              width: 8,
            ),
            Icon(
              Icons.keyboard_arrow_right,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
