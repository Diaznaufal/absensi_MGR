import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/detail_pengaduan.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PengaduanBerhasil extends StatelessWidget {
  final PengaduanModel pengaduanData; // <-- DIUBAH MENJADI PengaduanModel

  const PengaduanBerhasil({
    super.key,
    required this.pengaduanData, // <-- DIUBAH MENJADI PengaduanModel
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PengaduanPage(),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A49B7),
          elevation: 0,
          toolbarHeight: 0,
        ),
        backgroundColor: const Color(0xD7FFFFFF),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [_buildHeader()],
              ),
              Positioned(
                  top: screenHeight * 0.40,
                  left: 16,
                  right: 16,
                  child: _kodePengaduan(context, pengaduanData)),
              Positioned(
                  top: screenHeight * 0.55,
                  left: 16,
                  right: 16,
                  child: _peringatanCard()), // <-- Menggunakan pengaduanData
              Positioned(
                top: screenHeight * 0.65,
                left: 16,
                right: 16,
                child: InkWell(
                  onTap: () {
                    // SEKARANG BERSIH TANPA MAPPING MANUAL YANG ERROR (Mengatasi image_83ba57.png)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPengaduan(
                          pengaduan:
                              pengaduanData, // <-- Langsung dilempar tanpa error tipe data
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xff0a49b7),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "Lihat Detail Pengaduan",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.72,
                left: 16,
                right: 16,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PengaduanPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "Kembali Ke Riwayat",
                          style: GoogleFonts.poppins(
                              color: const Color(0xff0a49b7),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 60),
      decoration: const BoxDecoration(
          color: Color(0xFF0A49B7),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/pengaduanBerhasil.png',
            width: 350,
            height: 250,
          ),
          Text(
            'Pengaduan Berhasil Dikirim!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Terima kasih, pengaduan anda telah \nkami terima dan akan segera kami proses.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _kodePengaduan(BuildContext context, PengaduanModel pengaduan) {
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
              blurRadius: 10)
        ]),
    child: Column(
      children: [
        const Text("Kode Pengaduan"),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pengaduan.kodePengaduan,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A49B7),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: pengaduan.kodePengaduan,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Kode pengaduan berhasil disalin"),
                  ),
                );
              },
              child: const Icon(
                Icons.content_copy,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          DateFormat(
            'dd MMMM yyyy • HH:mm',
            'id_ID',
          ).format(
            pengaduan.tanggalPengaduan ?? DateTime.now(),
          ),
        )
      ],
    ),
  );
}

Widget _peringatanCard() {
  return Container(
    padding: const EdgeInsets.all(12),
    width: double.infinity,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 10)
        ]),
    child: Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 24,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Silahkan simpan kode pengaduan untuk melihat \nprogres kedepannya.',
          style: GoogleFonts.poppins(fontSize: 12),
        )
      ],
    ),
  );
}
