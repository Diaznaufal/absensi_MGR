import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// Path Import BLoC & Data
import '../bloc/dashboard_payroll/dashboard_payroll_bloc.dart';
import '../bloc/dashboard_payroll/dashboard_payroll_event.dart';
import '../bloc/dashboard_payroll/dashboard_payroll_state.dart';
import '../bloc/history_payroll/payroll_history_bloc.dart';
import '../bloc/history_payroll/payroll_history_event.dart';
import '../bloc/history_payroll/payroll_history_state.dart';
import '../../../data/models/response/payroll_response_model.dart';

import 'package:flutter_absensi_app/presentation/penggajian/pages/detail_penggajian.dart';
import 'package:flutter_absensi_app/presentation/penggajian/widgets/riwayat_gaji.dart';

class RingkasanKerja extends StatefulWidget {
  const RingkasanKerja({super.key});

  @override
  State<RingkasanKerja> createState() => _RingkasanKerjaState();
}

class _RingkasanKerjaState extends State<RingkasanKerja> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardPayrollBloc>().add(FetchCurrentPayroll());
    context
        .read<PayrollHistoryBloc>()
        .add(FetchPayrollHistory(DateTime.now().year));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: const Color(0xBAE7E8EC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // ==================== AREA FIXED / STATIS ====================
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildHeader(),
                    Positioned(
                      left: 12.w,
                      right: 12.w,
                      top: 87.h,
                      child: BlocBuilder<DashboardPayrollBloc,
                          DashboardPayrollState>(
                        builder: (context, state) {
                          if (state is DashboardPayrollLoading) {
                            return Container(
                              height: 180.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: const CircularProgressIndicator(),
                            );
                          } else if (state is DashboardPayrollLoaded) {
                            return _gajiKaryawan(state.data);
                          } else if (state is DashboardPayrollError) {
                            return _buildErrorCard(state.message);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),

                // Spacer untuk mengompensasi overlap card gaji
                SizedBox(height: 120.h),

                // Bagian Ringkasan Bulan Ini (Statis)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child:
                      BlocBuilder<DashboardPayrollBloc, DashboardPayrollState>(
                    builder: (context, state) {
                      if (state is DashboardPayrollLoaded) {
                        return _ringkasanGaji(state.data);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                SizedBox(height: 12.h),

                // ==================== AREA SCROLLABLE (HANYA RIWAYAT) ====================
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: BlocBuilder<PayrollHistoryBloc, PayrollHistoryState>(
                      builder: (context, state) {
                        if (state is PayrollHistoryLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is PayrollHistoryLoaded) {
                          return _riwayatGaji(state.history);
                        } else if (state is PayrollHistoryError) {
                          return Center(
                            child: Text(
                              state.message,
                              style:
                                  TextStyle(fontSize: 12.sp, color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 65.h),
      decoration: const BoxDecoration(
        color: Color(0xFF0A49B7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penggajian',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 13.sp),
              children: [
                TextSpan(
                  text: 'Hallo, ',
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
                ),
                TextSpan(
                  text: 'Karyawan 👋',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Berikut informasi gaji anda',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _gajiKaryawan(PayrollData data) {
    final String labelBulan = data.monthLabel ?? "-";
    final String labelTanggal = data.tanggalGajianLabel ?? "-";
    final String totalGajiBersih = data.gajiBersihFormatted ?? "Rp 0";

    final String statusKode = data.statusPembayaran?.kode ?? "";

    final String statusLabel =
        statusKode == 'dibayarkan' ? 'Dibayarkan' : 'Belum Dibayarkan';
    final Color badgeTextColor =
        statusKode == 'dibayarkan' ? Colors.green : Colors.amber;
    final Color badgeColor = statusKode == 'dibayarkan'
        ? Colors.green.shade50
        : Colors.amber.shade50;

    return Container(
      padding: EdgeInsets.all(12.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 8.r,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gaji Bersih Bulan ini',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      labelBulan,
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        totalGajiBersih,
                        style: GoogleFonts.poppins(
                            fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 11.r, color: Colors.grey.shade600),
                        SizedBox(width: 4.w),
                        Text(
                          labelTanggal,
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                          color: badgeTextColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Image.asset(
                    "assets/images/Wallet.png",
                    width: 75.r,
                    height: 75.r,
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: data.idPayrollComponent == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPenggajianPage(
                          idPayrollComponent: data.idPayrollComponent!,
                        ),
                      ),
                    ).then((_) {
                      context
                          .read<PayrollHistoryBloc>()
                          .add(FetchPayrollHistory(DateTime.now().year));
                    });
                  },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
              decoration: BoxDecoration(
                  color: data.idPayrollComponent == null
                      ? Colors.grey.shade200
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                        color: const Color(0xFFD8E4FD),
                        borderRadius: BorderRadius.circular(6.r)),
                    child: Icon(
                      Icons.feed_outlined,
                      color: const Color(0xFF0151E7),
                      size: 16.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Lihat Slip Gaji",
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_right, size: 18.r)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _ringkasanGaji(PayrollData data) {
    final String totalPenghasilan =
        data.ringkasan?.totalPenghasilanFormatted ?? "Rp 0";
    final String totalPotongan =
        data.ringkasan?.totalPotonganFormatted ?? "Rp 0";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ringkasan Bulan Ini",
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 3.1,
            children: [
              _buildTotalPenghasilan(
                  icon: Icons.north_east,
                  label: "Total Penghasilan",
                  subtitle: totalPenghasilan,
                  color: const Color(0x84BDF6D1)),
              _buildTotalPotongan(
                  icon: Icons.south_east,
                  label: "Total Potongan",
                  subtitle: totalPotongan,
                  color: const Color(0x9CFFDBE2))
            ]),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: const Color(0xFFD7E4FF),
              borderRadius: BorderRadius.circular(8.r)),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16.r, color: const Color(0xFF0151E7)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Rincian penghasilan, potongan, dan perhitungan lengkap bisa dilihat di slip gaji.",
                  style:
                      GoogleFonts.poppins(color: Colors.black, fontSize: 9.sp),
                  maxLines: 2,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _riwayatGaji(List<PayrollHistoryItem> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Riwayat Gaji",
          style:
              GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: history.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: Text("Belum ada riwayat penggajian",
                      style: TextStyle(fontSize: 12.sp)),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 5.h),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, index) {
                    final item = history[index];

                    return RiwayatGajiCard(
                      data: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPenggajianPage(
                              idPayrollComponent: item.idPayrollComponent!,
                            ),
                          ),
                        ).then((_) {
                          context
                              .read<PayrollHistoryBloc>()
                              .add(FetchPayrollHistory(DateTime.now().year));
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: EdgeInsets.all(12.r),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Center(
          child: Text(message,
              style: TextStyle(color: Colors.red, fontSize: 12.sp))),
    );
  }

  Widget _buildTotalPenghasilan({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: const Color(0xFFC0F0D1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: const Color(0xFF1F8B4D), size: 16.r),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                        fontSize: 9.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F8B4D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPotongan({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: const Color(0xFFFDD2DB),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: Colors.red, size: 16.r),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                        fontSize: 9.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
