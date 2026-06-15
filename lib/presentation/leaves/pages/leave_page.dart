import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/presentation/leaves/pages/add_leave_page.dart';
import 'package:flutter_absensi_app/presentation/leaves/pages/attachment_viewer_page.dart';
import '../model/model_leave.dart';
import '../provider/leave_provider.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: const Color(0xDEEFF0F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<LeaveProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _buildLeaveList(context, provider, dateFormatter),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
      child: Row(
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
    );
  }

  Widget _buildLeaveList(
      BuildContext context, LeaveProvider provider, DateFormat formatter) {
    final leaves = provider.listLeave;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          await Future<void>.delayed(const Duration(milliseconds: 600)),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        // Jumlah item selalu leaves.length + 1 karena index 0 adalah Summary Card
        itemCount: leaves.length + 1,
        separatorBuilder: (context, index) => const SpaceHeight(16),
        itemBuilder: (context, index) {
          // Index 0 AKAN SELALU menampilkan Summary Card (Tombol Apply)
          if (index == 0) {
            return _buildSummaryCard(context, leaves.length);
          }

          // Jika list data kosong tetapi index > 0, kita tampilkan placeholder kosong di bawah Summary Card
          if (leaves.isEmpty) {
            return _buildEmptyStateBelowCard();
          }

          // Render kartu cuti riwayat biasa
          final leave = leaves[index - 1];
          return _buildLeaveCard(context, provider, leave, formatter);
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
                    Text('Total Leaves',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9))),
                    Text('$totalLeaves request${totalLeaves == 1 ? '' : 's'}',
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddLeavePage()));
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text('Apply for Leave',
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
    final statusColor = leave.status.toLowerCase() == 'approved'
        ? AppColors.green
        : leave.status.toLowerCase() == 'rejected'
            ? AppColors.red
            : const Color(0xFFFFB020);

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
            child: Icon(
              provider.getLeaveIcon(leave
                  .leaveType), // Icon dinamis sesuai leaveType pilihan form
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
                          Text(leave.leaveType,
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black)),
                          const SpaceHeight(4),
                          Text(
                              '${formatter.format(leave.startDate)} - ${formatter.format(leave.endDate)}',
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
                        leave.status[0].toUpperCase() +
                            leave.status.substring(1),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(16),
                _buildInfoRow(Icons.timelapse_rounded, 'Total Days',
                    '${leave.totalDays} day${leave.totalDays == 1 ? '' : 's'}'),
                const SpaceHeight(12),
                _buildInfoRow(Icons.notes_rounded, 'Reason', leave.reason),
                const SpaceHeight(12),
                _buildInfoRow(
                    Icons.verified_user_rounded, 'Approver', leave.approver),
                if (leave.approvedAt != null) ...[
                  const SpaceHeight(12),
                  _buildInfoRow(Icons.event_available_rounded, 'Approved At',
                      formatter.format(leave.approvedAt!)),
                ],
                if (leave.attachmentPath != null) ...[
                  const SpaceHeight(12),
                  _buildAttachmentButton(context, leave.attachmentPath!),
                ]
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

  Widget _buildAttachmentButton(BuildContext context, String path) {
    final fileName = path.split('/').last;
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AttachmentViewerPage(attachmentUrl: path))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.attachment_rounded,
                color: AppColors.primary, size: 20),
            const SpaceWidth(8),
            Expanded(
              child: Text(fileName,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // State kosong yang ditaruh di bawah Summary Card agar UI tidak rusak
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
              'Belum ada riwayat cuti',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black),
            ),
            const SpaceHeight(4),
            Text(
              'Pengajuan cuti Anda akan muncul di sini.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
