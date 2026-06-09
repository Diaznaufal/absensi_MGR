import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/get_overtimes/get_overtimes_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/get_overtime_status/get_overtime_status_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/pages/checkin_checkout_overtime_page.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';

class OvertimePage extends StatefulWidget {
  const OvertimePage({super.key});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<GetOvertimesBloc>()
          .add(const GetOvertimesEvent.getOvertimes());
      context
          .read<GetOvertimeStatusBloc>()
          .add(const GetOvertimeStatusEvent.getOvertimeStatus());
    });
  }

  Future<void> _refreshData() async {
    context.read<GetOvertimesBloc>().add(const GetOvertimesEvent.getOvertimes());
    context
        .read<GetOvertimeStatusBloc>()
        .add(const GetOvertimeStatusEvent.getOvertimeStatus());
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _checkBackendAndNavigate(Function navigate) async {
    // Show loading indicator
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    // Check backend connection
    final isConnected = await BackendConnectionHelper.checkBackendSocket();

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (!mounted) return;

    if (isConnected) {
      // Backend is reachable, proceed with navigation
      await navigate();
    } else {
      // Backend is not reachable, show error dialog
      BackendConnectionDialog.show(
        context,
        customMessage: 'Tidak dapat terhubung ke backend saat ini',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 1.0],
            colors: [
              Color(0xFF1e3c72),
              Color(0xFF2a5298),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
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
                        const SpaceHeight(24),
                        _buildOvertimeActions(),
                        const SpaceHeight(32),
                        _buildHistorySection(),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SpaceWidth(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overtime',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your overtime records',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BlocBuilder<GetOvertimeStatusBloc, GetOvertimeStatusState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => _buildActionButtons('not_started', null),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            loaded: (status) =>
                _buildActionButtons(status.status ?? 'not_started', status.data),
            error: (message) => _buildErrorState(message),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(String status, Overtime? overtimeData) {
    final bool canCheckIn = status == 'not_started';
    final bool canCheckOut = status == 'in_progress';
    final bool isCompleted = status == 'completed';

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1e3c72), Color(0xFF3b82c9)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time_filled_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SpaceWidth(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overtime Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    _getStatusMessage(status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(status).withOpacity(0.3),
                ),
              ),
              child: Text(
                _getStatusLabel(status),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(status),
                ),
              ),
            ),
          ],
        ),
        const SpaceHeight(20),
        const Divider(height: 1),
        const SpaceHeight(20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canCheckIn ? AppColors.green : AppColors.grey.withOpacity(0.3),
                  foregroundColor: canCheckIn ? Colors.white : AppColors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canCheckIn ? 2 : 0,
                ),
                onPressed: canCheckIn
                    ? () async {
                        await _checkBackendAndNavigate(() async {
                          final result = await context.push(
                            const CheckInCheckOutOvertimePage(isCheckIn: true),
                          );
                          if (result == true && context.mounted) {
                            _refreshData();
                          }
                        });
                      }
                    : null,
                icon: const Icon(Icons.login_rounded, size: 20),
                label: Text(
                  'Check In',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SpaceWidth(12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canCheckOut ? AppColors.red : AppColors.grey.withOpacity(0.3),
                  foregroundColor: canCheckOut ? Colors.white : AppColors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canCheckOut ? 2 : 0,
                ),
                onPressed: canCheckOut && overtimeData != null
                    ? () async {
                        await _checkBackendAndNavigate(() async {
                          final result = await context.push(
                            CheckInCheckOutOvertimePage(
                              isCheckIn: false,
                              overtimeId: overtimeData.id,
                              overtimeData: overtimeData,
                            ),
                          );
                          if (result == true && context.mounted) {
                            _refreshData();
                          }
                        });
                      }
                    : null,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  'Check Out',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isCompleted) ...[
          const SpaceHeight(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SpaceWidth(12),
                Expanded(
                  child: Text(
                    'Overtime completed, waiting for approval',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.red,
          size: 32,
        ),
        const SpaceHeight(12),
        Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SpaceHeight(12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _refreshData,
          child: Text(
            'Retry',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SpaceHeight(16),
          BlocBuilder<GetOvertimesBloc, GetOvertimesState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () => _buildEmptyHistory(),
                loading: () => _buildLoadingHistory(),
                empty: () => _buildNoDataHistory(),
                error: (message) => _buildErrorHistory(message),
                loaded: (overtimes) => _buildHistoryList(overtimes),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHistory() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history_rounded,
            color: AppColors.primary,
            size: 48,
          ),
          const SpaceHeight(16),
          Text(
            'No History Yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SpaceHeight(8),
          Text(
            'Your overtime history will appear here',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            color: Colors.orange,
            size: 48,
          ),
          const SpaceHeight(16),
          Text(
            'No Overtime Records',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SpaceHeight(8),
          Text(
            'You haven\'t submitted any overtime yet',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHistory(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.red,
            size: 48,
          ),
          const SpaceHeight(16),
          Text(
            'Error Loading History',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SpaceHeight(8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Overtime> overtimes) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: overtimes.length,
      separatorBuilder: (context, index) => const SpaceHeight(16),
      itemBuilder: (context, index) {
        final overtime = overtimes[index];
        return _buildOvertimeCard(overtime);
      },
    );
  }

  Widget _buildOvertimeCard(Overtime overtime) {
    final dateFormatter = DateFormat('EEE, dd MMM yyyy');
    final statusColor = _getOvertimeStatusColor(overtime.status);
    final statusLabel = _getOvertimeStatusLabel(overtime.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
                    colors: [statusColor, statusColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getOvertimeStatusIcon(overtime.status),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SpaceWidth(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overtime.date != null
                          ? dateFormatter.format(DateTime.parse(overtime.date!))
                          : '-',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SpaceHeight(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
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
              Expanded(
                child: _buildTimeInfo(
                  'Start Time',
                  overtime.startTime ?? '-',
                  Icons.login_rounded,
                  AppColors.green,
                ),
              ),
              const SpaceWidth(16),
              Expanded(
                child: _buildTimeInfo(
                  'End Time',
                  overtime.endTime ?? '-',
                  Icons.logout_rounded,
                  AppColors.red,
                ),
              ),
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
          if (overtime.approvedAt != null) ...[
            const SpaceHeight(12),
            _buildInfoRow(
              'Approved At',
              DateFormat('dd MMM yyyy, HH:mm').format(overtime.approvedAt!),
              Icons.check_circle_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
      String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SpaceWidth(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: color.withOpacity(0.7),
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SpaceWidth(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
                const SpaceHeight(4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'not_started':
        return 'Ready to start overtime';
      case 'in_progress':
        return 'Overtime in progress';
      case 'completed':
        return 'Waiting for approval';
      default:
        return 'Unknown status';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'not_started':
        return 'Not Started';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'not_started':
        return AppColors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  Color _getOvertimeStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return AppColors.red;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _getOvertimeStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return status ?? 'Unknown';
    }
  }

  IconData _getOvertimeStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.pending_actions_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
