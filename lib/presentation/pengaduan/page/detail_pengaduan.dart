import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final timelineList = buildTimeline(pengaduan);
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _kembaliKePengaduan(context);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0A49B7),
          centerTitle: true,
          title: Text(
            "Detail Pengaduan",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              _kembaliKePengaduan(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 26.r,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF4F6F9),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 18.w : 14.w,
                  vertical: 14.h,
                ),
                child: Column(
                  children: [
                    _kodePengaduan(
                      context,
                      pengaduan,
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
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
                    SizedBox(height: 14.h),
                    _deskripsiPengaduan(
                      context,
                      pengaduan,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
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
      builder: (_) => const PengaduanPage(),
    ),
  );
}

Widget _kodePengaduan(
  BuildContext context,
  PengaduanModel pengaduan,
) {
  return Container(
    padding: EdgeInsets.all(16.r),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10.r,
          offset: Offset(0, 4.h),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          "Kode Pengaduan",
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          pengaduan.kodePengaduan,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A49B7),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _formatTanggal(pengaduan.tanggalPengaduan),
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.grey[600],
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
  final kategoriValue = value.trim();

  if (kategoriValue.isEmpty) {
    return "-";
  }

  final index = kategoriOptions.indexWhere(
    (e) =>
        e.value.toString().trim().toLowerCase() == kategoriValue.toLowerCase(),
  );

  if (index == -1) {
    return kategoriValue;
  }

  return kategoriOptions[index].title;
}

Widget _deskripsiPengaduan(
  BuildContext context,
  PengaduanModel pengaduan,
) {
  return Container(
    padding: EdgeInsets.all(16.r),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8.r,
          offset: Offset(0, 3.h),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _judulSection("Kategori"),
        SizedBox(height: 4.h),
        Text(
          _getKategoriTitle(
            pengaduan.kategori,
          ),
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        _judulSection("Judul Pengaduan"),
        SizedBox(height: 4.h),
        Text(
          pengaduan.judul.isNotEmpty ? pengaduan.judul : "-",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        _judulSection("Isi Pengaduan"),
        SizedBox(height: 4.h),
        Text(
          pengaduan.isi.isNotEmpty ? pengaduan.isi : "-",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        SizedBox(height: 14.h),
        _judulSection("Lampiran"),
        SizedBox(height: 8.h),
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
      fontSize: 13.5.sp,
      color: Colors.black,
    ),
  );
}

Widget _buildLampiran(
  BuildContext context,
  PengaduanModel pengaduan,
) {
  if (pengaduan.lampiran.isEmpty) {
    return Text(
      "-",
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        color: Colors.grey,
      ),
    );
  }

  return SizedBox(
    height: 105.h,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: pengaduan.lampiran.length,
      separatorBuilder: (_, __) {
        return SizedBox(width: 10.w);
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
  if (path.trim().isEmpty) {
    return _lampiranError();
  }

  final file = File(path);

  return GestureDetector(
    onTap: () {
      if (file.existsSync()) {
        _showPreviewLampiran(
          context,
          file,
        );
      }
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 125.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Image.file(
          file,
          fit: BoxFit.cover,
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
    width: 125.w,
    height: 105.h,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.broken_image_outlined,
          size: 24.r,
          color: Colors.grey,
        ),
        SizedBox(height: 4.h),
        Text(
          "Gambar tidak tersedia",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9.5.sp,
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
        insetPadding: EdgeInsets.all(16.r),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        height: 200.h,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40.r,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20.r,
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
