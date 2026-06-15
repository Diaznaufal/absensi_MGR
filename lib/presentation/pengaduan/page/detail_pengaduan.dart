import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/kategoriOptions.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/timeline_list.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_page.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/widget/pengaduan_timeline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class DetailPengaduan extends StatelessWidget {
  final PengaduanModel pengaduan;

  const DetailPengaduan({
    super.key,
    required this.pengaduan,
  });
  @override
  Widget build(BuildContext context) {
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PengaduanPage()),
                );
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _kodePengaduan(context, pengaduan),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(77),
                              blurRadius: 5,
                              spreadRadius: 1)
                        ]),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: buildTimeline(pengaduan).length,
                      itemBuilder: (context, index) {
                        return TimelineCard(
                          timeline: buildTimeline(pengaduan)[index],
                          isLast: index == buildTimeline(pengaduan).length - 1,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  _deskripsiPengaduan(context, pengaduan)
                ],
              ),
            ),
          ))),
    );
  }
}

Widget _kodePengaduan(BuildContext context, PengaduanModel pengaduan) {
  return Container(
    padding: EdgeInsets.all(14),
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
        Text(
          "Kode Pengaduan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          pengaduan.kodePengaduan,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A49B7),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          DateFormat(
            'dd MMMM yyyy • HH:mm',
            'id_ID',
          ).format(
            pengaduan.tanggalPengaduan,
          ),
          style: GoogleFonts.poppins(fontSize: 12),
        )
      ],
    ),
  );
}

Widget _deskripsiPengaduan(BuildContext context, PengaduanModel pengaduan) {
  String getKategoriTitle(String value) {
    return kategoriOptions
        .firstWhere(
          (e) => e.value == value,
        )
        .title;
  }

  return Container(
    padding: EdgeInsets.all(14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kategori",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          getKategoriTitle(pengaduan.kategori),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          "Judul Pengaduan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          pengaduan.judul,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          "Isi Pengaduan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          pengaduan.isi,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          "Lampiran",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        pengaduan.lampiran.isEmpty
            ? Text(
                "-",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )
            : SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pengaduan.lampiran.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.file(
                          File(pengaduan.lampiran[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    ),
  );
}
