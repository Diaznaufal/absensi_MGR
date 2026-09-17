import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/presentation/penggajian/pages/payroll_pdf_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Path Import BLoC & Model Universal
import '../bloc/history_payroll/payroll_history_bloc.dart';
import '../bloc/history_payroll/payroll_history_event.dart';
import '../bloc/history_payroll/payroll_history_state.dart';
import '../../../data/models/response/payroll_response_model.dart';

final rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class DetailPenggajianPage extends StatefulWidget {
  final int idPayrollComponent;

  const DetailPenggajianPage({super.key, required this.idPayrollComponent});

  @override
  State<DetailPenggajianPage> createState() => _DetailPenggajianPageState();
}

class _DetailPenggajianPageState extends State<DetailPenggajianPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PayrollHistoryBloc>()
        .add(FetchPayrollDetail(widget.idPayrollComponent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF6EFEFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: 56.h,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20.r),
            ),
            SizedBox(width: 16.w),
            Text(
              'Slip Gaji',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<PayrollHistoryBloc, PayrollHistoryState>(
              builder: (context, state) {
                if (state is PayrollHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PayrollDetailLoaded) {
                  final detail = state.detail;
                  return _buildContent(detail);
                } else if (state is PayrollHistoryError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        state.message,
                        style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PayrollData detail) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPeriode(detail),
          SizedBox(height: 14.h),
          _buildDataKaryawan(detail.karyawan),
          SizedBox(height: 14.h),
          _buildCardPenghasilan(
              detail.penghasilan, detail.ringkasan?.totalPenghasilanFormatted),
          SizedBox(height: 14.h),
          _buildCardPotongan(detail.potongan,
              detail.ringkasan?.totalPotonganFormatted, detail.kehadiran),
          SizedBox(height: 14.h),
          _buildCardPerhitunganBersih(detail.ringkasan),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () {
                PayrollPdfService.generateSlipGaji(detail);
              },
              icon: Icon(Icons.download, color: Colors.blue, size: 18.r),
              label: Text(
                'Download Slip Gaji (PDF)',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  // 1. Bagian Bulan & Tanggal Bayar
  Widget _buildHeaderPeriode(PayrollData detail) {
    String formatBulan(String? rawDate) {
      if (rawDate == null || rawDate.isEmpty) return '';
      try {
        DateTime parseDate = DateTime.parse(rawDate);
        return DateFormat('MMMM yyyy', 'id_ID').format(parseDate);
      } catch (e) {
        return rawDate;
      }
    }

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.calendar_today_rounded,
                    color: Colors.blue, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatBulan(detail.periodeGajian),
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      detail.tanggalGajianLabel ?? "Belum tersedia",
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: const Color(0xFFBFDBFE).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'Gaji Bersih',
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    detail.ringkasan?.gajiBersihFormatted ?? "Rp 0",
                    style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1D4ED8)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 3. Widget Detail Data Karyawan
  Widget _buildDataKaryawan(Karyawan? karyawan) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Karyawan',
            style: GoogleFonts.poppins(
                fontSize: 12.5.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          _buildRowDetail('NIP', ':  ${karyawan?.nip ?? "-"}'),
          _buildRowDetail('Nama', karyawan?.name ?? "-"),
          _buildRowDetail('Divisi', karyawan?.divisi ?? "-"),
          _buildRowDetail('Posisi', karyawan?.jabatan ?? "-"),
        ],
      ),
    );
  }

  // 4. Widget Bagian Penghasilan Dinamis
  Widget _buildCardPenghasilan(
      List<PayrollItem>? listPenghasilan, String? totalFormatted) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6.r)),
                      child: Icon(Icons.wallet_rounded,
                          color: Colors.green, size: 16.r),
                    ),
                    SizedBox(width: 8.w),
                    Text('PENGHASILAN',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green)),
                  ],
                ),
                SizedBox(height: 10.h),
                if (listPenghasilan != null)
                  ...listPenghasilan.map((item) => _buildRowDetail(
                      item.label ?? "-", item.formatted ?? "Rp 0")),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Penghasilan',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(totalFormatted ?? "Rp 0",
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.green)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardPotongan(List<PayrollItem>? listPotongan,
      String? totalFormatted, Kehadiran? kehadiran) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6.r)),
                      child: Icon(Icons.receipt_long_rounded,
                          color: Colors.red, size: 16.r),
                    ),
                    SizedBox(width: 8.w),
                    Text('POTONGAN',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red)),
                  ],
                ),
                SizedBox(height: 10.h),
                if (listPotongan != null)
                  ...listPotongan.map((item) {
                    String? subLabel;
                    if (item.label?.toLowerCase().contains('absen') == true &&
                        kehadiran != null) {
                      subLabel = '(${kehadiran.totalAbsen ?? 0} Hari)';
                    }
                    return _buildRowDetail(
                        item.label ?? "-", item.formatted ?? "Rp 0",
                        subLeft: subLabel);
                  }),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Potongan',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(totalFormatted ?? "Rp 0",
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.red)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardPerhitunganBersih(Ringkasan? ringkasan) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERHITUNGAN GAJI BERSIH',
            style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700]),
          ),
          SizedBox(height: 10.h),
          _buildRowDetail('Total Penghasilan',
              ringkasan?.totalPenghasilanFormatted ?? "Rp 0",
              isBoldLeft: true),
          _buildRowDetail(
              '- Total Potongan', ringkasan?.totalPotonganFormatted ?? "Rp 0",
              colorRight: Colors.red),
          Divider(height: 18.h, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gaji Bersih',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[800])),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ringkasan?.gajiBersihFormatted ?? "Rp 0",
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue[700]),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Helper Widget Row Detail
  Widget _buildRowDetail(
    String leftText,
    String rightText, {
    String? subLeft,
    Color? colorRight,
    bool isBoldLeft = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    leftText,
                    style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        color: Colors.black87,
                        fontWeight:
                            isBoldLeft ? FontWeight.w600 : FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (subLeft != null) ...[
                  SizedBox(width: 4.w),
                  Text(
                    subLeft,
                    style: GoogleFonts.poppins(
                        fontSize: 10.5.sp, color: Colors.grey[500]),
                  ),
                ]
              ],
            ),
          ),
          SizedBox(width: 8.w),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              rightText,
              style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: colorRight ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
