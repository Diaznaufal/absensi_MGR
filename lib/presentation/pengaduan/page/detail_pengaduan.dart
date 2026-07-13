import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/kategoriOptions.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/timeline_list.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_page.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/widget/pengaduan_timeline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailPengaduan extends StatelessWidget {
  final PengaduanModel pengaduan;

  const DetailPengaduan({
    super.key,
    required this.pengaduan,
  });

  @override
  Widget build(BuildContext context) {
    // Build sekali saja agar tidak dipanggil berulang-ulang
    final timelineList = buildTimeline(pengaduan);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _kembaliKePengaduan(context);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0A49B7),
          centerTitle: true,
          title: Text(
            "Detail Pengaduan",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              _kembaliKePengaduan(context);
            },
            icon: const Icon(
              Icons.keyboard_arrow_left,
              size: 27,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xD7FFFFFF),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                children: [
                  _kodePengaduan(
                    context,
                    pengaduan,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(
                        timelineList.length,
                        (index) {
                          return TimelineCard(
                            timeline: timelineList[index],
                            isLast: index == timelineList.length - 1,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _deskripsiPengaduan(
                    context,
                    pengaduan,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _kembaliKePengaduan(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => PengaduanPage(),
    ),
  );
}

Widget _kodePengaduan(
  BuildContext context,
  PengaduanModel pengaduan,
) {
  return Container(
    padding: const EdgeInsets.all(14),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          "Kode Pengaduan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          pengaduan.kodePengaduan,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A49B7),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _formatTanggal(pengaduan.tanggalPengaduan),
          style: GoogleFonts.poppins(
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

String _formatTanggal(DateTime tanggal) {
  try {
    return DateFormat(
      'dd MMMM yyyy • HH:mm',
      'id_ID',
    ).format(tanggal);
  } catch (e) {
    return "-";
  }
}

String _getKategoriTitle(String value) {
  // Bersihkan value
  final kategoriValue = value.trim();

  // Kalau kosong
  if (kategoriValue.isEmpty) {
    return "-";
  }

  // Cari index kategori yang cocok
  final index = kategoriOptions.indexWhere(
    (e) =>
        e.value.toString().trim().toLowerCase() == kategoriValue.toLowerCase(),
  );

  // Jika tidak ditemukan
  if (index == -1) {
    // Tetap tampilkan value asli
    // daripada aplikasi crash
    return kategoriValue;
  }

  // Jika ditemukan
  return kategoriOptions[index].title;
}

Widget _deskripsiPengaduan(
  BuildContext context,
  PengaduanModel pengaduan,
) {
  return Container(
    padding: const EdgeInsets.all(14),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _judulSection("Kategori"),
        const SizedBox(height: 4),
        Text(
          _getKategoriTitle(
            pengaduan.kategori,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        _judulSection("Judul Pengaduan"),
        const SizedBox(height: 4),
        Text(
          pengaduan.judul.isNotEmpty ? pengaduan.judul : "-",
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        _judulSection("Isi Pengaduan"),
        const SizedBox(height: 4),
        Text(
          pengaduan.isi.isNotEmpty ? pengaduan.isi : "-",
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        _judulSection("Lampiran"),
        const SizedBox(height: 6),
        _buildLampiran(
          context,
          pengaduan,
        ),
      ],
    ),
  );
}

Widget _judulSection(String title) {
  return Text(
    title,
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

Widget _buildLampiran(
  BuildContext context,
  PengaduanModel pengaduan,
) {
  // Jika tidak ada lampiran
  if (pengaduan.lampiran.isEmpty) {
    return Text(
      "-",
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  return SizedBox(
    height: 120,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: pengaduan.lampiran.length,
      separatorBuilder: (_, __) {
        return const SizedBox(width: 10);
      },
      itemBuilder: (context, index) {
        final path = pengaduan.lampiran[index];

        return _lampiranItem(
          context,
          path,
        );
      },
    ),
  );
}

Widget _lampiranItem(
  BuildContext context,
  String path,
) {
  // Jika path kosong
  if (path.trim().isEmpty) {
    return _lampiranError();
  }

  final file = File(path);

  return GestureDetector(
    onTap: () {
      // Hanya buka preview jika file tersedia
      if (file.existsSync()) {
        _showPreviewLampiran(
          context,
          file,
        );
      }
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.file(
          file,
          fit: BoxFit.cover,

          // Jika gambar gagal dibuka
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _lampiranError();
          },
        ),
      ),
    ),
  );
}

Widget _lampiranError() {
  return Container(
    width: 140,
    height: 120,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.broken_image_outlined,
          size: 30,
          color: Colors.grey,
        ),
        const SizedBox(height: 5),
        Text(
          "Gambar tidak tersedia",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

void _showPreviewLampiran(
  BuildContext context,
  File file,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Gambar
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        height: 250,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Tombol close
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
