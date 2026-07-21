import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

final rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class RingkasanKerja extends StatefulWidget {
  const RingkasanKerja({super.key});

  @override
  State<RingkasanKerja> createState() => _RingkasanKerjaState();
}

class _RingkasanKerjaState extends State<RingkasanKerja> {
  @override
  void initState() {
    super.initState();
    // Pemicu awal data dari kedua BLoC saat halaman dibuka
    context.read<DashboardPayrollBloc>().add(FetchCurrentPayroll());
    context
        .read<PayrollHistoryBloc>()
        .add(FetchPayrollHistory(DateTime.now().year));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: const Color(0xBAE7E8EC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
              ],
            ),
            Positioned(
              top: screenHeight * 0.12,
              left: 16,
              right: 16,
              child: BlocBuilder<DashboardPayrollBloc, DashboardPayrollState>(
                builder: (context, state) {
                  if (state is DashboardPayrollLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DashboardPayrollLoaded) {
                    return _gajiKaryawan(state.data);
                  } else if (state is DashboardPayrollError) {
                    return _buildErrorCard(state.message);
                  }
                  return const SizedBox();
                },
              ),
            ),
            Positioned(
              top: screenHeight * 0.38,
              left: 16,
              right: 16,
              child: BlocBuilder<DashboardPayrollBloc, DashboardPayrollState>(
                builder: (context, state) {
                  if (state is DashboardPayrollLoaded) {
                    return _ringkasanGaji(state.data);
                  }
                  return const SizedBox();
                },
              ),
            ),
            Positioned(
              top: screenHeight * 0.580,
              left: 16,
              right: 16,
              bottom: screenHeight * 0.003,
              child: BlocBuilder<PayrollHistoryBloc, PayrollHistoryState>(
                builder: (context, state) {
                  if (state is PayrollHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PayrollHistoryLoaded) {
                    return _riwayatGaji(state.history);
                  } else if (state is PayrollHistoryError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 60),
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
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                    text: 'Hallo, ',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                TextSpan(
                    text: 'Karyawan 👋',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
          Text(
            'Berikut informasi gaji anda',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
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
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gaji Bersih Bulan ini',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labelBulan,
                    style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    totalGajiBersih,
                    style: GoogleFonts.poppins(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        labelTanggal,
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                          color: badgeTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    "assets/images/Wallet.png",
                    width: 95,
                    height: 95,
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: data.idPayrollComponent == null
                      ? Colors.grey.shade200
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFD8E4FD),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.feed_outlined,
                      color: Color(0xFF0151E7),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Lihat Slip Gaji",
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_right, size: 22)
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
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
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
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFD7E4FF),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 20, color: Color(0xFF0151E7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Rincian penghasilan, potongan, dan perhitungan lengkap bisa dilihat di slip gaji.",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 10),
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
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: history.isEmpty
              ? const Center(child: Text("Belum ada riwayat penggajian"))
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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
        const SizedBox(height: 5)
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(
          child: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildTotalPenghasilan({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFC0F0D1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1F8B4D), size: 20),
          ),
          const SizedBox(width: 6),
          // [DIUBAH] Tambahkan Expanded & FittedBox agar teks menyesuaikan sisa lebar
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
                        fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFFDD2DB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 6),
          // [DIUBAH] Tambahkan Expanded & FittedBox agar teks menyesuaikan sisa lebar
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
                        fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
