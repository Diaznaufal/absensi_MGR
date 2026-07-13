import 'package:flutter/material.dart';
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
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 22),
            ),
            const SizedBox(width: 20),
            Text(
              'Slip Gaji',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<PayrollHistoryBloc, PayrollHistoryState>(
        builder: (context, state) {
          if (state is PayrollHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PayrollDetailLoaded) {
            final detail = state.detail;
            return _buildContent(detail);
          } else if (state is PayrollHistoryError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  style: GoogleFonts.poppins(
                      color: Colors.red, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(PayrollData detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPeriode(detail),
          const SizedBox(height: 16),
          _buildDataKaryawan(detail.karyawan),
          const SizedBox(height: 20),
          _buildCardPenghasilan(
              detail.penghasilan, detail.ringkasan?.totalPenghasilanFormatted),
          const SizedBox(height: 20),
          _buildCardPotongan(detail.potongan,
              detail.ringkasan?.totalPotonganFormatted, detail.kehadiran),
          const SizedBox(height: 20),
          _buildCardPerhitunganBersih(detail.ringkasan),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                PayrollPdfService.generateSlipGaji(detail);
              },
              icon: const Icon(Icons.download, color: Colors.blue),
              label: Text(
                'Download Slip Gaji (PDF)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatBulan(detail.periodeGajian),
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.tanggalGajianLabel ?? "Belum tersedia",
                    style:
                        GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFFBFDBFE).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'Gaji Bersih',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  detail.ringkasan?.gajiBersihFormatted ?? "Rp 0",
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D4ED8)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Karyawan',
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildRowDetail('NIP', ':  ${karyawan?.nip ?? "-"}'),
          _buildRowDetail('Nama', karyawan?.name ?? "-"),
          _buildRowDetail('Divisi', karyawan?.divisi ?? "-"),
          _buildRowDetail('Posisi', karyawan?.jabatan ?? "-"),
        ],
      ),
    );
  }

  // 4. Widget Bagian Penghasilan Dinamis (Mapping List)
  Widget _buildCardPenghasilan(
      List<PayrollItem>? listPenghasilan, String? totalFormatted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.wallet_rounded,
                          color: Colors.green, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('PENGHASILAN',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                if (listPenghasilan != null)
                  ...listPenghasilan.map((item) => _buildRowDetail(
                      item.label ?? "-", item.formatted ?? "Rp 0")),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Penghasilan',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
                Text(totalFormatted ?? "Rp 0",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.red, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('POTONGAN',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Potongan',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red)),
                Text(totalFormatted ?? "Rp 0",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.red)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardPerhitunganBersih(Ringkasan? ringkasan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERHITUNGAN GAJI BERSIH',
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          _buildRowDetail('Total Penghasilan',
              ringkasan?.totalPenghasilanFormatted ?? "Rp 0",
              isBoldLeft: true),
          _buildRowDetail(
              '- Total Potongan', ringkasan?.totalPotonganFormatted ?? "Rp 0",
              colorRight: Colors.red),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gaji Bersih',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[800])),
              Text(
                ringkasan?.gajiBersihFormatted ?? "Rp 0",
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue[700]),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Helper Widget Tetap Sama
  Widget _buildRowDetail(
    String leftText,
    String rightText, {
    String? subLeft,
    Color? colorRight,
    bool isBoldLeft = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                leftText,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: isBoldLeft ? FontWeight.w600 : FontWeight.w400),
              ),
              if (subLeft != null) ...[
                const SizedBox(width: 8),
                Text(
                  subLeft,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[500]),
                ),
              ]
            ],
          ),
          Text(
            rightText,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorRight ?? Colors.black),
          ),
        ],
      ),
    );
  }
}
