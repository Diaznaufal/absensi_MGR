import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/detail_pengaduan.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PengaduanBerhasil extends StatelessWidget {
  final PengaduanModel pengaduanData;

  const PengaduanBerhasil({
    super.key,
    required this.pengaduanData,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PengaduanPage(),
            ),
          );
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0A49B7),
          body: Container(
            color: const Color(0xFF0A49B7),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Transform.translate(
                        offset: Offset(0, -35.h),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Column(
                            children: [
                              _kodePengaduan(context, pengaduanData),
                              SizedBox(height: 10.h),
                              _peringatanCard(),
                              SizedBox(height: 18.h),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailPengaduan(
                                        pengaduan: pengaduanData,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  width: double.infinity,
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF0A49B7),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(color: Colors.white),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white,
                                          blurRadius: 3,
                                        )
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Lihat Detail Pengaduan",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PengaduanPage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  width: double.infinity,
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white,
                                          blurRadius: 3,
                                        )
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Kembali Ke Riwayat",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5.sp,
                                        color: const Color(0xFF0A49B7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, statusBarHeight + 10.h, 14.w, 65.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0A49B7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45.r),
          bottomRight: Radius.circular(45.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/pengaduanBerhasil.png',
            width: 280.w,
            height: 180.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h),
          Text(
            'Pengaduan Berhasil Dikirim!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Terima kasih, pengaduan anda telah \nkami terima dan akan segera kami proses.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kodePengaduan(BuildContext context, PengaduanModel pengaduan) {
    return Container(
      padding: EdgeInsets.all(16.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pengaduan.kodePengaduan,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A49B7),
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: pengaduan.kodePengaduan,
                    ),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Kode pengaduan berhasil disalin",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.content_copy,
                    size: 18.r,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            DateFormat(
              'dd MMMM yyyy • HH:mm',
              'id_ID',
            ).format(
              pengaduan.tanggalPengaduan ?? DateTime.now(),
            ),
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _peringatanCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 22.r,
            color: const Color(0xFF0A49B7),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Silahkan simpan kode pengaduan untuk melihat progres kedepannya.',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
