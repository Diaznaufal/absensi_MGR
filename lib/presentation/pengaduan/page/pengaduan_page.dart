import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_page.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/buat_pengaduan.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/widget/riwayat_pengaduan.dart';

import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_event.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final TextEditingController kodeController = TextEditingController();

  void _cariPengaduan() {
    final kode = kodeController.text.trim();

    if (kode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Masukkan kode pengaduan terlebih dahulu",
            style: GoogleFonts.poppins(fontSize: 12.sp),
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<PengaduanBloc>().add(
          CariPengaduanByKodeEvent(
            kodePengaduan: kode,
          ),
        );
  }

  @override
  void dispose() {
    kodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainPage(),
          ),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0A49B7),
          centerTitle: true,
          title: Text(
            "Pengaduan Karyawan",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainPage(),
                ),
                (route) => false,
              );
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 26.r,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFE7EAEC),
        body: SafeArea(
          child: Center(
            // Menjaga tampilan di tablet tetap rapi dan tidak melar
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16.w : 12.w,
                  vertical: 10.h,
                ),
                child: Column(
                  children: [
                    // =========================
                    // CARD BUAT PENGADUAN
                    // =========================
                    Container(
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
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sampaikan keluhan atau \naspirasi anda",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Setiap laporan akan ditangani secara profesional dan terjaga kerahasiaannya",
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BuatPengaduan(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 11.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A49B7),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Buat Pengaduan",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // =========================
                    // CARD RIWAYAT
                    // =========================
                    Expanded(
                      child: Container(
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
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Riwayat Pengaduan",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Cari riwayat pengaduan anda menggunakan kode pengaduan",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // =========================
                              // SEARCH FIELD & BUTTON
                              // =========================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: kodeController,
                                      textInputAction: TextInputAction.search,
                                      style:
                                          GoogleFonts.poppins(fontSize: 12.sp),
                                      onSubmitted: (_) => _cariPengaduan(),
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan kode pengaduan',
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: 11.5.sp,
                                          color: Colors.grey[400],
                                        ),
                                        prefixIconConstraints: BoxConstraints(
                                          minWidth: 36.w,
                                        ),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.only(
                                            left: 10.w,
                                            right: 6.w,
                                          ),
                                          child: Icon(
                                            Icons.search,
                                            color: Colors.black87,
                                            size: 18.r,
                                          ),
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          borderSide: BorderSide(
                                            color: Colors.blue[800]!,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 8.w),

                                  // =========================
                                  // TOMBOL CARI
                                  // =========================
                                  BlocBuilder<PengaduanBloc, PengaduanState>(
                                    buildWhen: (previous, current) =>
                                        current is CariPengaduanLoading ||
                                        current is CariPengaduanSuccess ||
                                        current is CariPengaduanNotFound ||
                                        current is CariPengaduanFailure,
                                    builder: (context, state) {
                                      final isLoading =
                                          state is CariPengaduanLoading;

                                      return SizedBox(
                                        height: 44.h,
                                        child: ElevatedButton(
                                          onPressed:
                                              isLoading ? null : _cariPengaduan,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0052CC),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10.r,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                                  width: 16.r,
                                                  height: 16.r,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Text(
                                                  'Cari',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.5.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // =========================
                              // HASIL PENCARIAN (SCROLLABLE)
                              // =========================
                              Expanded(
                                child:
                                    BlocBuilder<PengaduanBloc, PengaduanState>(
                                  buildWhen: (previous, current) =>
                                      current is CariPengaduanLoading ||
                                      current is CariPengaduanSuccess ||
                                      current is CariPengaduanNotFound ||
                                      current is CariPengaduanFailure,
                                  builder: (context, state) {
                                    if (state is CariPengaduanLoading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (state is CariPengaduanSuccess) {
                                      final item = state.pengaduan;

                                      return SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: RiwayatPengaduanCard(
                                            code: item.kodePengaduan,
                                            tanggal: item.tanggalPengaduan ??
                                                DateTime.now(),
                                            status: item.status,
                                            pengaduan: item,
                                          ),
                                        ),
                                      );
                                    }

                                    if (state is CariPengaduanNotFound) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.search_off_rounded,
                                              size: 42.r,
                                              color: Colors.grey[350],
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Kode pengaduan tidak ditemukan",
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (state is CariPengaduanFailure) {
                                      return Center(
                                        child: Text(
                                          state.message,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5.sp,
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    }

                                    return Center(
                                      child: Text(
                                        "Masukkan kode pengaduan\nuntuk melihat riwayat",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
