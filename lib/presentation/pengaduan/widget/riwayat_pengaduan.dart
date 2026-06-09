import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RiwayatPengaduanCard extends StatelessWidget {
  final String code;
  final DateTime tanggal;
  final AttendanceStatus status;

  const RiwayatPengaduanCard({
    super.key,
    required this.code,
    required this.tanggal,
    required this.status,
  });

  String getRiwayatStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.menungguProses:
        return "Menunggu Verifikasi";
      case AttendanceStatus.proses:
        return "Dalam Proses";
      case AttendanceStatus.selesai:
        return "Selesai";
      case AttendanceStatus.ditolak:
        return "Ditolak";
    }
  }

  Color getRiwayatColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.menungguProses:
        return Color(0xffF59E0B);
      case AttendanceStatus.proses:
        return Color(0xff3B82F6);
      case AttendanceStatus.selesai:
        return Color(0xff009236);
      case AttendanceStatus.ditolak:
        return Color(0xFFF53A0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

enum AttendanceStatus {
  menungguProses,
  proses,
  selesai,
  ditolak,
}
