import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../blocs/create_overtime/create_overtime_bloc.dart';
import '../blocs/get_overtimes/get_overtimes_bloc.dart';
import '../../../data/models/response/overtime_response_model.dart';

class OvertimePage extends StatefulWidget {
  const OvertimePage({super.key});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  @override
  void initState() {
    super.initState();
    context.read<GetOvertimesBloc>().add(const GetOvertimesEvent.fetch());
  }

  Future<void> _refreshData() async {
    context.read<GetOvertimesBloc>().add(const GetOvertimesEvent.fetch());
  }

  String _calculateTimeSpend(String startStr, String endStr) {
    if (startStr.isEmpty || endStr.isEmpty) return "0.00";
    try {
      final format = DateFormat("HH:mm");
      final start = format.parse(startStr);
      var end = format.parse(endStr);

      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }

      final difference = end.difference(start);
      final hours = difference.inMinutes / 60.0;
      return hours
          .toStringAsFixed(2); 
    } catch (e) {
      return "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A49B7),
      body: SafeArea(
        child: BlocListener<CreateOvertimeBloc, CreateOvertimeState>(
          listener: (context, state) {
            state.maybeWhen(
              loading: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
              success: (response) {
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(response.message ?? 'Lembur berhasil diajukan'),
                    backgroundColor: AppColors.green,
                  ),
                );
                _refreshData(); 
              },
              error: (message) {
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.red,
                  ),
                );
              },
              orElse: () {},
            );
          },
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
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 22),
          ),
          const SpaceWidth(20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lembur',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              Text(
                'Kelola riwayat lembur Anda',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOvertimeActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF0A49B7),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.access_time_filled_rounded,
                    color: Colors.white, size: 24),
              ),
              const SpaceWidth(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Lembur',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black)),
                    Text(
                        'Silakan ajukan rencana lembur Anda melalui tombol di bawah.',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SpaceHeight(20),
          const Divider(height: 1),
          const SpaceHeight(20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A49B7).withOpacity(0.08),
              foregroundColor: const Color(0xFF0A49B7),
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0A49B7), width: 1.2)),
            ),
            icon: const Icon(Icons.edit_calendar_rounded, size: 20),
            label: Text('Ajukan Lembur',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            onPressed: () => _showManualOvertimeBottomSheet(context),
          ),
        ],
      ),
    );
  }

  void _showManualOvertimeBottomSheet(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dateController = TextEditingController(text: todayStr);
    final startController = TextEditingController();
    final endController = TextEditingController();
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bCtx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(bCtx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Form Lembur',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SpaceHeight(16),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Tanggal Lembur',
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder()),
                ),
                const SpaceHeight(16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startController,
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: 'Jam Mulai *',
                            suffixIcon: Icon(Icons.access_time_rounded),
                            border: OutlineInputBorder()),
                        onTap: () async {
                          final time = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            setModalState(() => startController.text =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                          }
                        },
                      ),
                    ),
                    const SpaceWidth(16),
                    Expanded(
                      child: TextField(
                        controller: endController,
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: 'Jam Selesai *',
                            suffixIcon: Icon(Icons.access_time_rounded),
                            border: OutlineInputBorder()),
                        onTap: () async {
                          final time = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            setModalState(() => endController.text =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(16),
                TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                        labelText: 'Deskripsi / Alasan Lembur *',
                        border: OutlineInputBorder())),
                const SpaceHeight(24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A49B7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (startController.text.isNotEmpty &&
                          endController.text.isNotEmpty &&
                          reasonController.text.isNotEmpty) {
                        final calculatedSpend = _calculateTimeSpend(
                            startController.text, endController.text);

                        // Eksekusi BLoC Event submit dengan kalkulasi otomatis time Spend
                        context
                            .read<CreateOvertimeBloc>()
                            .add(CreateOvertimeEvent.submit(
                              date: dateController.text,
                              startTime: startController.text,
                              endTime: endController.text,
                              timeSpend: calculatedSpend,
                              description: reasonController.text,
                            ));
                        Navigator.pop(context); // Menutup BottomSheet Form
                      }
                    },
                    child: Text('Ajukan Lembur',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Riwayat',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white)),
          const SpaceHeight(16),
          BlocBuilder<GetOvertimesBloc, GetOvertimesState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (message) => Center(
                    child: Text(message,
                        style: const TextStyle(color: Colors.white))),
                success: (response) {
                  final history = response.data ?? [];
                  if (history.isEmpty) {
                    return _buildNoDataHistory();
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SpaceHeight(16),
                    itemBuilder: (context, index) =>
                        _buildOvertimeCard(history[index]),
                  );
                },
                orElse: () => _buildNoDataHistory(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataHistory() {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: Colors.orange, size: 50),
          const SpaceHeight(16),
          Text('No Overtime Records',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black)),
          const SpaceHeight(8),
          Text('You haven\'t submitted any overtime yet',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Menerima Objek Overtime murni dari Model API final
  Widget _buildOvertimeCard(Overtime overtime) {
    final statusColor = _getOvertimeStatusColor(overtime.statusLabel);
    final statusLabel = overtime.statusLabel ?? 'Pending';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(_getOvertimeStatusIcon(overtime.statusLabel),
                    color: Colors.white, size: 24),
              ),
              const SpaceWidth(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan string properti 'tanggal' dari API
                    Text(overtime.tanggal ?? '-',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black)),
                    const SpaceHeight(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3))),
                      child: Text(statusLabel,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
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
              // Menampilkan string jam 'start' dan 'end' dari API
              Expanded(
                  child: _buildTimeInfo('Start Time', overtime.start ?? '-',
                      Icons.login_rounded, AppColors.green)),
              const SpaceWidth(16),
              Expanded(
                  child: _buildTimeInfo('End Time', overtime.end ?? '-',
                      Icons.logout_rounded, AppColors.red)),
            ],
          ),
          const SpaceHeight(12),
          // Menampilkan string durasi 'time_spend' desimal dari API
          _buildInfoRow('Total Durasi', '${overtime.timeSpend ?? '0'} Jam',
              Icons.timelapse_rounded),
          // Menampilkan 'description' (alasan lembur) dari API
          if (overtime.description != null &&
              overtime.description!.isNotEmpty) ...[
            const SpaceHeight(12),
            _buildInfoRow(
                'Deskripsi', overtime.description!, Icons.notes_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SpaceWidth(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: color.withOpacity(0.7))),
                Text(time,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color)),
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
      decoration: BoxDecoration(
          color: AppColors.light.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SpaceWidth(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.grey)),
                const SpaceHeight(4),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOvertimeStatusColor(String? statusLabel) {
    switch (statusLabel?.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return AppColors.green;
      case 'ditolak':
      case 'rejected':
        return AppColors.red;
      default:
        return Colors.orange; // Default status pending / Menunggu Persetujuan
    }
  }

  IconData _getOvertimeStatusIcon(String? statusLabel) {
    switch (statusLabel?.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return Icons.check_circle_rounded;
      case 'ditolak':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }
}
