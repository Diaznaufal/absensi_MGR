import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../provider/overtime_provider.dart';
import '../model/overtime_model.dart';

class OvertimePage extends StatefulWidget {
  const OvertimePage({super.key});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshData() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  // Fungsi Dialog Konfirmasi Absen dengan Teks Bahasa yang Lebih Humanis (Tidak Kaku)
  void _showActionConfirmationDialog({required bool isCheckIn, required VoidCallback onConfirm}) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              color: isCheckIn ? AppColors.green : AppColors.red,
              size: 24,
            ),
            const SpaceWidth(12),
            Text(
              isCheckIn ? 'Mulai Lembur Sekarang?' : 'Selesai Lembur Sekarang?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCheckIn 
                  ? 'Apakah Anda yakin ingin mencatat waktu mulai lembur Anda saat ini?' 
                  : 'Apakah Anda yakin ingin mengakhiri dan mencatat waktu selesai lembur Anda?',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            const SpaceHeight(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Waktu Absen:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey)),
                  Text(timeStr, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCheckIn ? AppColors.green : AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              isCheckIn ? 'Ya, Mulai' : 'Ya, Selesai', 
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A49B7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SpaceHeight(14),
                      _buildOvertimeActions(context),
                      const SpaceHeight(32),
                      _buildHistorySection(context),
                      const SpaceHeight(24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          const SpaceWidth(20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lembur',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              Text(
                'Kelola riwayat lembur Anda',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOvertimeActions(BuildContext context) {
    final provider = context.watch<OvertimeProvider>();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: _buildActionButtons(context, provider.currentStatus),
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    final provider = context.watch<OvertimeProvider>();
    final history = provider.historyList;
    
    // =========================================================================
    // LOGIKA TRACKING OTOMATIS BERDASARKAN FILTER TANGGAL HARI INI & ATURAN JAM
    // =========================================================================
    bool isTimeValidToCheckIn = false;
    String statusAlertMessage = 'Harap isi form "Ajukan Lembur" terlebih dahulu';

    if (history.isNotEmpty) {
      final now = DateTime.now();
      final formattedToday = DateFormat('yyyy-MM-dd').format(now);

      // 1. Cari apakah ada pengajuan lembur manual yang tanggalnya ADALAH HARI INI
      final OvertimeModel? todaySchedule = history.cast<OvertimeModel?>().firstWhere(
        (element) => element != null && element.date == formattedToday && element.status == 'pending',
        orElse: () => null,
      );

      if (todaySchedule != null && todaySchedule.startTime != null) {
        final timeStr = todaySchedule.startTime!;
        final scheduledDateTime = DateTime.parse('$formattedToday $timeStr:00');

        // 2. Hitung selisih waktu sekarang dengan jadwal mulai lembur (dalam Menit)
        final differenceInMinutes = scheduledDateTime.difference(now).inMinutes;

        // Tombol baru menyala hijau jika waktu sekarang sudah masuk gerbang maksimal 2 jam (120 menit) sebelum jadwal
        if (differenceInMinutes <= 120) {
          isTimeValidToCheckIn = true;
          statusAlertMessage = _getStatusMessage(status);
        } else {
          statusAlertMessage = 'Tombol aktif pada hari-H (Maksimal 2 jam sebelum jam $timeStr)';
        }
      } else {
        statusAlertMessage = 'Tidak ada jadwal lembur manual untuk hari ini';
      }
    }
    // =========================================================================

    final bool canCheckIn = history.isNotEmpty && status == 'not_started' && isTimeValidToCheckIn;
    final bool canCheckOut = history.isNotEmpty && status == 'in_progress';
    final bool isCompleted = history.isNotEmpty && status == 'completed';

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A49B7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 24),
            ),
            const SpaceWidth(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overtime Status',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.black),
                  ),
                  Text(
                    statusAlertMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 12, 
                      color: !isTimeValidToCheckIn && status == 'not_started' ? Colors.red : AppColors.grey
                    ),
                  ),
                ],
              ),
            ),
            if (history.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (canCheckIn || canCheckOut || isCompleted ? _getStatusColor(status) : AppColors.grey).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (canCheckIn || canCheckOut || isCompleted ? _getStatusColor(status) : AppColors.grey).withOpacity(0.3)),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: GoogleFonts.poppins(
                    fontSize: 11, 
                    fontWeight: FontWeight.w600, 
                    color: canCheckIn || canCheckOut || isCompleted ? _getStatusColor(status) : AppColors.grey
                  ),
                ),
              ),
          ],
        ),
        const SpaceHeight(20),
        const Divider(height: 1),
        const SpaceHeight(20),

        // 1. TOMBOL AJUKAN LEMBUR MANUAL (Selalu aktif untuk input data/alasan)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A49B7).withOpacity(0.08),
            foregroundColor: const Color(0xFF0A49B7),
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF0A49B7), width: 1.2)),
          ),
          icon: const Icon(Icons.edit_calendar_rounded, size: 20),
          label: Text('Ajukan Lembur Manual (Susulan/Rencana)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          onPressed: () => _showManualOvertimeBottomSheet(context),
        ),
        
        const SpaceHeight(14),

        // 2. TOMBOL ABSENSI REAL-TIME VALIDASI (Hasil Tracking Otomatis)
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCheckIn ? AppColors.green : AppColors.grey.withOpacity(0.3),
                  foregroundColor: canCheckIn ? Colors.white : AppColors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: canCheckIn ? 2 : 0,
                ),
                onPressed: canCheckIn
                    ? () {
                        _showActionConfirmationDialog(
                          isCheckIn: true,
                          onConfirm: () {
                            context.read<OvertimeProvider>().startOvertime();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Center(child: Text('Validasi Check In Berhasil!')), backgroundColor: AppColors.green),
                            );
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.login_rounded, size: 20),
                label: Text('Check In', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SpaceWidth(12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCheckOut ? AppColors.red : AppColors.grey.withOpacity(0.3),
                  foregroundColor: canCheckOut ? Colors.white : AppColors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: canCheckOut ? 2 : 0,
                ),
                onPressed: canCheckOut
                    ? () {
                        _showActionConfirmationDialog(
                          isCheckIn: false,
                          onConfirm: () {
                            context.read<OvertimeProvider>().endOvertime();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Center(child: Text('Validasi Check Out Berhasil!')), backgroundColor: AppColors.green),
                            );
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text('Check Out', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        if (isCompleted) ...[
          const SpaceHeight(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 20),
                const SpaceWidth(12),
                Expanded(child: Text('Validasi absen selesai, menunggu persetujuan admin', style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange))),
              ],
            ),
          ),
          const SpaceHeight(12),
          TextButton(
            onPressed: () => context.read<OvertimeProvider>().resetSimulasi(),
            child: Text('Reset Sesi Simulasi', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }

  void _showManualOvertimeBottomSheet(BuildContext context) {
    final dateController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Form Lembur Manual (Susulan)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SpaceHeight(16),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Tanggal Lembur *', suffixIcon: Icon(Icons.calendar_today_rounded), border: OutlineInputBorder()),
                  onTap: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now.subtract(const Duration(days: 30)),
                      lastDate: now.add(const Duration(days: 365 * 5)), // Fleksibel untuk lusa atau masa depan
                    );
                    if (pickedDate != null) {
                      setModalState(() => dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate));
                    }
                  },
                ),
                const SpaceHeight(16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Jam Mulai *', suffixIcon: Icon(Icons.access_time_rounded), border: OutlineInputBorder()),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            setModalState(() => startController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                          }
                        },
                      ),
                    ),
                    const SpaceWidth(16),
                    Expanded(
                      child: TextField(
                        controller: endController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Jam Selesai *', suffixIcon: Icon(Icons.access_time_rounded), border: OutlineInputBorder()),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            setModalState(() => endController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(16),
                TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Alasan Lembur *', hintText: 'Contoh: Mengerjakan project yang dikejar deadline hari ini', border: OutlineInputBorder())),
                const SpaceHeight(16),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Catatan (Opsional)', border: OutlineInputBorder())),
                const SpaceHeight(24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A49B7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (dateController.text.isNotEmpty && startController.text.isNotEmpty && endController.text.isNotEmpty && reasonController.text.isNotEmpty) {
                        context.read<OvertimeProvider>().addManualOvertime(
                          date: dateController.text,
                          startTime: startController.text,
                          endTime: endController.text,
                          reason: reasonController.text,
                          notes: notesController.text.isEmpty ? null : notesController.text,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Center(child: Text('Lembur susulan berhasil diajukan!')), backgroundColor: AppColors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Center(child: Text('Harap isi seluruh kolom wajib (*)')), backgroundColor: AppColors.red),
                        );
                      }
                    },
                    child: Text('Ajukan Lembur', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SpaceHeight(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final history = context.watch<OvertimeProvider>().historyList;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white)),
          const SpaceHeight(16),
          if (history.isEmpty) _buildNoDataHistory() else _buildHistoryList(history),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<OvertimeModel> overtimes) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: overtimes.length,
      separatorBuilder: (context, index) => const SpaceHeight(16),
      itemBuilder: (context, index) => _buildOvertimeCard(overtimes[index]),
    );
  }

  Widget _buildNoDataHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: Colors.orange, size: 48),
          const SpaceHeight(16),
          Text('No Overtime Records', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black)),
          const SpaceHeight(8),
          Text('You haven\'t submitted any overtime yet', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOvertimeCard(OvertimeModel overtime) {
    final dateFormatter = DateFormat('EEE, dd MMM yyyy');
    final statusColor = _getOvertimeStatusColor(overtime.status);
    final statusLabel = _getOvertimeStatusLabel(overtime.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [statusColor, statusColor.withOpacity(0.7)]), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getOvertimeStatusIcon(overtime.status), color: Colors.white, size: 24),
              ),
              const SpaceWidth(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(overtime.date != null ? dateFormatter.format(DateTime.parse(overtime.date!)) : '-', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black)),
                    const SpaceHeight(4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                      child: Text(statusLabel, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SpaceHeight(16),
          const Divider(height: 1),
          const SpaceHeight(16),
          Row(
            children: [
              Expanded(child: _buildTimeInfo('Start Time', overtime.startTime ?? '-', Icons.login_rounded, AppColors.green)),
              const SpaceWidth(16),
              Expanded(child: _buildTimeInfo('End Time', overtime.endTime ?? '-', Icons.logout_rounded, AppColors.red)),
            ],
          ),
          if (overtime.reason != null && overtime.reason!.isNotEmpty) ...[
            const SpaceHeight(16),
            _buildInfoRow('Reason', overtime.reason!, Icons.notes_rounded),
          ],
          if (overtime.notes != null && overtime.notes!.isNotEmpty) ...[
            const SpaceHeight(12),
            _buildInfoRow('Notes', overtime.notes!, Icons.description_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SpaceWidth(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: color.withOpacity(0.7))),
                Text(time, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.light.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SpaceWidth(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey)),
                const SpaceHeight(4),
                Text(value, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'not_started': return 'Ready to start overtime';
      case 'in_progress': return 'Overtime in progress';
      case 'completed': return 'Waiting for approval';
      default: return 'Unknown status';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'not_started': return 'Not Started';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'not_started': return AppColors.grey;
      case 'in_progress': return Colors.blue;
      case 'completed': return Colors.orange;
      default: return AppColors.primary;
    }
  }

  Color _getOvertimeStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return AppColors.green;
      case 'rejected': return AppColors.red;
      case 'pending': return Colors.orange;
      default: return AppColors.primary;
    }
  }

  String _getOvertimeStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'pending': return 'Pending';
      default: return status ?? 'Unknown';
    }
  }

  IconData _getOvertimeStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      case 'pending': return Icons.pending_actions_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}