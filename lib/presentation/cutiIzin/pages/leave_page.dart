import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/pages/add_izin_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/pages/add_leave_page.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/pages/attachment_viewer_page.dart';
import '../model/model_leave.dart';
import '../model/model_izin.dart';
import '../provider/leave_provider.dart';
import '../provider/izin_provider.dart'; // PENTING: Pastikan import ini ada

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  @override
  void initState() {
    super.initState();
    // Memicu pengambilan data Cuti & Izin secara otomatis saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().getLeaveHistory();
      context.read<IzinProvider>().getIzinHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 22),
            ),
            const SpaceWidth(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permintaan Cuti dan Izin',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  'Pantau dan kelola pengajuan cuti anda',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xDEEFF0F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Menggunakan Consumer2 untuk mendengarkan LeaveProvider dan IzinProvider sekaligus
              child: Consumer2<LeaveProvider, IzinProvider>(
                builder: (context, leaveProvider, izinProvider, child) {
                  // Tampilkan loading jika salah satu provider sedang mengambil data
                  if (leaveProvider.isLoading || izinProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A49B7),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _buildLeaveAndIzinList(
                        context, leaveProvider, izinProvider, dateFormatter),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveAndIzinList(
      BuildContext context,
      LeaveProvider leaveProvider,
      IzinProvider izinProvider,
      DateFormat formatter) {
    final leaves = leaveProvider.listLeave;
    final izins = izinProvider.listIzin;

    // Menghitung total gabungan riwayat
    final totalGabungan = leaves.length + izins.length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        // Mendukung Pull-to-Refresh secara manual untuk kedua data
        await leaveProvider.getLeaveHistory();
        await izinProvider.getIzinHistory();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        // Jumlah item: 1 Summary Card + (jika kosong tampilkan 1 empty state, jika ada data tampilkan totalnya)
        itemCount: totalGabungan == 0 ? 2 : totalGabungan + 1,
        separatorBuilder: (context, index) => const SpaceHeight(16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(context, totalGabungan);
          }

          if (totalGabungan == 0) {
            return _buildEmptyStateBelowCard();
          }

          // Index data dikurangi 1 karena index 0 dipakai SummaryCard
          final dataIndex = index - 1;

          // Tampilkan data Cuti terlebih dahulu, kemudian data Izin di bawahnya
          if (dataIndex < leaves.length) {
            final leave = leaves[dataIndex];
            return _buildLeaveCard(context, leaveProvider, leave, formatter);
          } else {
            final izin = izins[dataIndex - leaves.length];
            return _buildIzinCard(context, izin, formatter);
          }
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int totalLeaves) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0A49B7),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.event_note_rounded,
                    color: Colors.white, size: 28),
              ),
              const SpaceWidth(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pengajuan Cuti & Izin',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9))),
                    Text('$totalLeaves Pengajuan',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SpaceHeight(20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Provider.of<LeaveProvider>(context, listen: false).resetForm();
                Provider.of<IzinProvider>(context, listen: false).resetForm();

                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Text(
                              'Pilih Jenis Pengajuan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            const SpaceHeight(10),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(55),
                                        spreadRadius: 1,
                                        blurRadius: 5)
                                  ]),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColors.primary),
                                ),
                                title: Text('Ajukan Cuti',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    'Menggunakan sisa kuota cuti tahunan/sakit/darurat',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: AppColors.grey)),
                                onTap: () async {
                                  Navigator.pop(context);

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddLeavePage()));

                                  if (context.mounted) {
                                    context
                                        .read<LeaveProvider>()
                                        .getLeaveHistory();
                                  }
                                },
                              ),
                            ),
                            const SpaceHeight(8),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(55),
                                        spreadRadius: 1,
                                        blurRadius: 5)
                                  ]),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.money_off_rounded,
                                      color: Colors.red),
                                ),
                                title: Text('Ajukan Izin',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    'Izin tidak masuk kerja di luar kuota cuti (Potong Gaji)',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: AppColors.grey)),
                                onTap: () async {
                                  Navigator.pop(context);

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddIzinPage()));

                                  // Menarik data Izin terbaru setelah halaman form ditutup
                                  if (context.mounted) {
                                    context
                                        .read<IzinProvider>()
                                        .getIzinHistory();
                                  }
                                },
                              ),
                            ),
                            const SpaceHeight(12),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text('Ajukan Cuti / Izin',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, LeaveProvider provider,
      LeaveModel leave, DateFormat formatter) {
    final statusLower = leave.status.toLowerCase();

    String statusText = 'Pending';
    Color statusColor = const Color(0xFFFFB020);
    String persetujuanText = 'Menunggu Persetujuan HR/Admin';

    if (statusLower == '2' ||
        statusLower == 'approved' ||
        statusLower == 'diterima') {
      statusText = 'Diterima';
      statusColor = AppColors.green;
      persetujuanText = 'Diterima oleh HR/Admin';
    } else if (statusLower == '1' ||
        statusLower == 'rejected' ||
        statusLower == 'ditolak') {
      statusText = 'Ditolak';
      statusColor = AppColors.red;
      persetujuanText = 'Ditolak oleh HR/Admin';
    }

    // 🌟 LOGIKA PEMBERSIH TEKS ALASAN: Menghapus format '[Cuti Tahunan] - ' jika ada
    String cleanReason = leave.description;
    if (cleanReason.contains('] - ')) {
      cleanReason = cleanReason.split('] - ').last;
    } else if (cleanReason.contains('] ')) {
      cleanReason = cleanReason.split('] ').last;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10))
        ],
        border: Border.all(color: AppColors.light.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A49B7),
              borderRadius: BorderRadius.circular(18),
            ),
            // 🌟 SINKRONISASI IKON: Memastikan mengambil ikon dinamis dari provider
            child: Icon(
              provider.getLeaveIcon(leave.leaveType),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SpaceWidth(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🌟 SINKRONISASI JUDUL: Memastikan judul Jenis Cuti (Cuti Tahunan / Cuti Sakit) muncul di atas
                          Text(
                            leave.leaveType.isNotEmpty
                                ? leave.leaveType
                                : 'Cuti Karyawan',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black),
                          ),
                          const SpaceHeight(4),
                          Text(
                              '${formatter.format(leave.startDate)}${leave.endDate != null ? ' - ${formatter.format(leave.endDate!)}' : ''}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(16),
                _buildInfoRow(Icons.timelapse_rounded, 'Total Hari',
                    '${leave.totalDays} hari'),
                const SpaceHeight(12),
                // 🌟 UPDATE FIELD ALASAN: Menggunakan string cleanReason yang sudah dibersihkan dari bracket
                _buildInfoRow(Icons.notes_rounded, 'Alasan', cleanReason),
                const SpaceHeight(12),
                _buildInfoRow(Icons.verified_user_rounded, 'Persetujuan',
                    persetujuanText),
                if (leave.approvedAt != null) ...[
                  const SpaceHeight(12),
                  _buildInfoRow(Icons.event_available_rounded, 'Approved At',
                      formatter.format(leave.approvedAt!)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET UPDATE: Card Khusus Tampilan Riwayat Izin dengan Status & Total Hari & Info Persetujuan Dinamis
  Widget _buildIzinCard(
      BuildContext context, ModelIzin izin, DateFormat formatter) {
    // 1. Tentukan warna status secara dinamis berdasarkan data 'status' dari BE ('0', '1', '2')
    Color statusColor = const Color(0xFFFFB020); // Default Kuning (Pending)
    String persetujuanText =
        'Menunggu Persetujuan HRD/Admin'; // 🌟 Sinkronisasi Teks Default

    if (izin.status == '2') {
      statusColor = AppColors.green; // Hijau (Disetujui)
      persetujuanText = 'Diterima oleh HRD/Admin'; // 🌟 Dinamis jika diterima
    } else if (izin.status == '1') {
      statusColor = AppColors.red; // Merah (Ditolak)
      persetujuanText = 'Ditolak oleh HRD/Admin'; // 🌟 Dinamis jika ditolak
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10))
        ],
        border: Border.all(color: AppColors.light.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A49B7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assignment_ind_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SpaceWidth(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            izin.alasanIzin,
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black),
                          ),
                          const SpaceHeight(4),
                          Text(
                            '${formatter.format(izin.tanggalIzin)}${izin.endDate != null ? ' - ${formatter.format(izin.endDate!)}' : ''}',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        izin.statusLabel, // Mengambil getter otomatis (Pending/Disetujui/Ditolak)
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(16),
                _buildInfoRow(Icons.timelapse_rounded, 'Total Hari',
                    '${izin.calculatedTotalDays} hari'),
                const SpaceHeight(12),
                _buildInfoRow(Icons.notes_rounded, 'Keterangan',
                    izin.description.isNotEmpty ? izin.description : '-'),
                const SpaceHeight(12),
                // PERBAIKAN: Menambahkan Info Row Persetujuan agar sinkron dengan Cuti
                _buildInfoRow(Icons.verified_user_rounded, 'Persetujuan',
                    persetujuanText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SpaceWidth(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: AppColors.grey)),
              const SpaceHeight(4),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateBelowCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SpaceHeight(16),
            Text(
              'Belum ada riwayat cuti & izin',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black),
            ),
            const SpaceHeight(4),
            Text(
              'Pengajuan Anda akan muncul di sini.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
