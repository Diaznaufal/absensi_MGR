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
        return "Menunggu";

      case statusPengaduan.dalamProses:
        return "Dalam Proses";

      case statusPengaduan.selesai:
        return "Selesai";
      case statusPengaduan.tidakselesai:
        return "Tidak Selesai";
    }
  }

  Color getRiwayatColor(statusPengaduan status) {
    switch (status) {
      case statusPengaduan.menunggu:
        return const Color(0xFFF59E0B);

      case statusPengaduan.dalamProses:
        return const Color(0xFF3B82F6);

      case statusPengaduan.selesai:
        return const Color(0xFF009236);
      case statusPengaduan.tidakselesai:
        return const Color(0xFFF10000);
    }
  }

  Color getRiwayatBackgroundColor(statusPengaduan status) {
    switch (status) {
      case statusPengaduan.menunggu:
        return const Color(0xFFFFF7E6);

      case statusPengaduan.dalamProses:
        return const Color(0xFFEFF6FF);

      case statusPengaduan.selesai:
        return const Color(0xFFEAF8EF);
      case statusPengaduan.tidakselesai:
        return const Color(0xFFF8EAEA);
    }
  }

  void _bukaDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPengaduan(
          pengaduan: pengaduan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // Padding dibuat sedikit lebih compact
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE1E5EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        // PENTING:
        // Card hanya mengambil tinggi sesuai isi
        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ============================
          // CODE + STATUS
          // ============================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF252525),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getRiwayatBackgroundColor(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getRiwayatStatus(status),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: getRiwayatColor(status),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================
          // TANGGAL
          // ============================
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            text: DateFormat(
              'dd MMMM yyyy',
              'id_ID',
            ).format(tanggal),
          ),

          const SizedBox(height: 8),

          // ============================
          // KATEGORI
          // ============================
          _buildInfoRow(
            icon: Icons.sell_outlined,
            text: _getKategoriText(),
          ),

          const SizedBox(height: 8),

          // ============================
          // JUDUL
          // ============================
          _buildInfoRow(
            icon: Icons.chat_bubble_outline,
            text: pengaduan.judul.isNotEmpty ? pengaduan.judul : '-',
          ),

          const SizedBox(height: 12),

          // ============================
          // DIVIDER
          // ============================
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE7E9ED),
          ),

          const SizedBox(height: 8),

          // ============================
          // LIHAT DETAIL
          // ============================
          InkWell(
            onTap: () => _bukaDetail(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Lihat Detail",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A49B7),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_right,
                    size: 22,
                    color: Color(0xFF0A49B7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF252525),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  String _getKategoriText() {
    if (pengaduan.kategoriLainnya != null &&
        pengaduan.kategoriLainnya!.trim().isNotEmpty) {
      return pengaduan.kategoriLainnya!;
    }

    if (pengaduan.kategori.isNotEmpty) {
      return pengaduan.kategori;
    }

    return '-';
  }
}
