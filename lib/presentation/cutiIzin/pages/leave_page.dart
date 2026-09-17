import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/pages/add_izin_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/pages/add_leave_page.dart';
import '../model/model_leave.dart';
import '../model/model_izin.dart';
import '../provider/leave_provider.dart';
import '../provider/izin_provider.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().getLeaveHistory();
      context.read<IzinProvider>().getIzinHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy');
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Permintaan Cuti dan Izin',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pantau dan kelola pengajuan cuti anda',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xDEEFF0F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                Expanded(
                  child: Consumer2<LeaveProvider, IzinProvider>(
                    builder: (context, leaveProvider, izinProvider, child) {
                      final bool isFirstTimeLoading =
                          (leaveProvider.isLoading || izinProvider.isLoading) &&
                              leaveProvider.listLeave.isEmpty &&
                              izinProvider.listIzin.isEmpty;

                      if (isFirstTimeLoading) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16.w : 12.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            children: [
                              _buildSummaryCard(context, 0),
                              SizedBox(height: 20.h),
                              const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0A49B7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16.w : 12.w,
                          vertical: 10.h,
                        ),
                        child: _buildLeaveAndIzinList(
                          context,
                          leaveProvider,
                          izinProvider,
                          dateFormatter,
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
    );
  }

  Widget _buildLeaveAndIzinList(
    BuildContext context,
    LeaveProvider leaveProvider,
    IzinProvider izinProvider,
    DateFormat formatter,
  ) {
    final leaves = leaveProvider.listLeave;
    final izins = izinProvider.listIzin;
    final totalGabungan = leaves.length + izins.length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await leaveProvider.getLeaveHistory();
        await izinProvider.getIzinHistory();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32.h),
        itemCount: totalGabungan == 0 ? 2 : totalGabungan + 1,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(context, totalGabungan);
          }

          if (totalGabungan == 0) {
            return _buildEmptyStateBelowCard();
          }

          final dataIndex = index - 1;

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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: const Color(0xFF0A49B7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A49B7).withOpacity(0.2),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengajuan Cuti & Izin',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '$totalLeaves Pengajuan',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                Provider.of<LeaveProvider>(context, listen: false).resetForm();
                Provider.of<IzinProvider>(context, listen: false).resetForm();
                _showSelectionBottomSheet(context);
              },
              icon: Icon(Icons.add_circle_outline_rounded, size: 20.r),
              label: Text(
                'Ajukan Cuti / Izin',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 14.h),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        Text(
                          'Pilih Jenis Pengajuan',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        _buildModalOption(
                          title: 'Ajukan Cuti',
                          subtitle:
                              'Menggunakan sisa kuota cuti tahunan/sakit/darurat',
                          icon: Icons.calendar_today_rounded,
                          iconColor: AppColors.primary,
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddLeavePage(),
                              ),
                            );
                            if (context.mounted) {
                              context.read<LeaveProvider>().getLeaveHistory();
                            }
                          },
                        ),
                        SizedBox(height: 10.h),
                        _buildModalOption(
                          title: 'Ajukan Izin',
                          subtitle:
                              'Izin tidak masuk kerja di luar kuota cuti (Potong Gaji)',
                          icon: Icons.money_off_rounded,
                          iconColor: Colors.red,
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddIzinPage(),
                              ),
                            );
                            if (context.mounted) {
                              context.read<IzinProvider>().getIzinHistory();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 6.r,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.r),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 10.5.sp,
            color: AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(
    BuildContext context,
    LeaveProvider provider,
    LeaveModel leave,
    DateFormat formatter,
  ) {
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

    String cleanReason = leave.description;
    if (cleanReason.contains('] - ')) {
      cleanReason = cleanReason.split('] - ').last;
    } else if (cleanReason.contains('] ')) {
      cleanReason = cleanReason.split('] ').last;
    }

    final String dateDisplay =
        '${formatter.format(leave.startDate)}${leave.endDate != null ? ' - ${formatter.format(leave.endDate!)}' : ''}';

    return _buildUnifiedCard(
      title: leave.leaveType.isNotEmpty ? leave.leaveType : 'Cuti Karyawan',
      dateText: dateDisplay,
      statusLabel: statusText,
      statusColor: statusColor,
      icon: provider.getLeaveIcon(leave.leaveType),
      rows: [
        _InfoData(
            Icons.timelapse_rounded, 'Total Hari', '${leave.totalDays} hari'),
        _InfoData(Icons.notes_rounded, 'Alasan', cleanReason),
        _InfoData(Icons.verified_user_rounded, 'Persetujuan', persetujuanText),
        if (leave.approvedAt != null)
          _InfoData(
            Icons.event_available_rounded,
            'Approved At',
            formatter.format(leave.approvedAt!),
          ),
      ],
    );
  }

  Widget _buildIzinCard(
    BuildContext context,
    ModelIzin izin,
    DateFormat formatter,
  ) {
    Color statusColor = const Color(0xFFFFB020);
    String persetujuanText = 'Menunggu Persetujuan HRD/Admin';

    if (izin.status == '2') {
      statusColor = AppColors.green;
      persetujuanText = 'Diterima oleh HRD/Admin';
    } else if (izin.status == '1') {
      statusColor = AppColors.red;
      persetujuanText = 'Ditolak oleh HRD/Admin';
    }

    final String dateDisplay =
        '${formatter.format(izin.tanggalIzin)}${izin.endDate != null ? ' - ${formatter.format(izin.endDate!)}' : ''}';

    return _buildUnifiedCard(
      title: izin.alasanIzin,
      dateText: dateDisplay,
      statusLabel: izin.statusLabel,
      statusColor: statusColor,
      icon: Icons.assignment_ind_rounded,
      rows: [
        _InfoData(
          Icons.timelapse_rounded,
          'Total Hari',
          '${izin.calculatedTotalDays} hari',
        ),
        _InfoData(
          Icons.notes_rounded,
          'Keterangan',
          izin.description.isNotEmpty ? izin.description : '-',
        ),
        _InfoData(Icons.verified_user_rounded, 'Persetujuan', persetujuanText),
      ],
    );
  }

  Widget _buildUnifiedCard({
    required String title,
    required String dateText,
    required String statusLabel,
    required Color statusColor,
    required IconData icon,
    required List<_InfoData> rows,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(color: AppColors.light.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFF0A49B7),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22.r,
            ),
          ),
          SizedBox(width: 10.w),
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
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            dateText,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) SizedBox(height: 8.h),
                  _buildInfoRow(rows[i].icon, rows[i].label, rows[i].value),
                ],
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
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 14.r),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateBelowCard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                color: AppColors.primary,
                size: 32.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Belum ada riwayat cuti & izin',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Pengajuan Anda akan muncul di sini.',
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoData {
  final IconData icon;
  final String label;
  final String value;

  _InfoData(this.icon, this.label, this.value);
}
