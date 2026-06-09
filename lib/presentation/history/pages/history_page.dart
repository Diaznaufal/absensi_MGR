import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/history/blocs/absensi.dart';
import 'package:flutter_absensi_app/presentation/history/blocs/get_all_attendances/get_all_attendances_bloc.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_absensi_app/presentation/history/pages/detail_history_page.dart';
import 'package:flutter_absensi_app/presentation/history/pages/widgets/riwayat_absensi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../../../core/core.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedDate = DateTime.now();

  // @override
  // void initState() {
  //   super.initState();GetAllAttendancesEvent.getAllAttendances()
  //   Future.microtask(() {
  //     context
  //         .read<GetAllAttendancesBloc>()
  //         .add(const GetAllAttendancesEvent.getAllAttendances());
  //   });
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Color(0xFF0A49B7),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xBAE7E8EC)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildAttendanceList([])
                  //     BlocBuilder<GetAllAttendancesBloc, GetAllAttendancesState>(
                  //   builder: (context, state) {
                  //     return state.maybeWhen(
                  //       orElse: () => _buildEmptyState(),
                  //       loading: () => _buildLoadingState(),
                  //       empty: () => _buildNoDataState(),
                  //       error: (message) => _buildErrorState(message),
                  //       loaded: (attendances) =>
                  //           _buildAttendanceList(attendances),
                  //     );
                  //   },
                  // ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFF0A49B7)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // context
    //     .read<GetAllAttendancesBloc>()
    //     .add(const GetAllAttendancesEvent.getAllAttendances());
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF1e3c72),
                    size: 48,
                  ),
                ),
                const SpaceHeight(16),
                Text(
                  'Select Date',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SpaceHeight(8),
                Text(
                  'No attendance data available',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),
                const SpaceHeight(16),
                Text(
                  'No Attendance Records',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SpaceHeight(8),
                Text(
                  'You have no attendance history yet',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataForSelectedDateState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue,
                    size: 48,
                  ),
                ),
                const SpaceHeight(16),
                Text(
                  'Tidak ada data untuk tanggal ini',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SpaceHeight(8),
                Text(
                  'No attendance records found for ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SpaceHeight(16),
                Text(
                  'Error Loading Data',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SpaceHeight(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(List<Attendance> attendances) {
    // Filter out weekends and holidays
    var filteredAttendances = attendances
        .where((attendance) =>
            attendance.isWeekend != true && attendance.isHoliday != true)
        .toList();

    // Filter by selected date if any
    // if (_selectedDate != null) {
    //   filteredAttendances = filteredAttendances.where((attendance) {
    //     if (attendance.date == null) return false;
    //     return attendance.date!.year == _selectedDate.year &&
    //         attendance.date!.month == _selectedDate.month &&
    //         attendance.date!.day == _selectedDate.day;
    //   }).toList();
    // }

    //   if (filteredAttendances.isEmpty) {
    //     return _buildNoDataForSelectedDateState();
    //   }
    // }

    // if (filteredAttendances.isEmpty) {
    //   return _buildNoDataState();
    // }

    // Sort by date descending (newest first)
    filteredAttendances.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    //
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildPresencePercentageCard(_selectedDate),
            const SizedBox(height: 14),
            _buildStatisticCard(_selectedDate),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Absensi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF253B80),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: histories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 5),
                itemBuilder: (_, index) {
                  final item = histories[index];

                  return AttendanceHistoryCard(
                    day: item.day,
                    date: item.date,
                    checkIn: item.checkIn,
                    checkOut: item.checkOut,
                    status: item.status,
                    note: item.note,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final dateFormatter = DateFormat('EEE, dd MMM yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final statusColor = _getStatusColor(attendance.status);
    final statusLabel = _getStatusLabel(attendance.status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailHistoryPage(attendance: attendance),
          ),
        );
      },
      child: Container(
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
            // Header with date and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(attendance.status),
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
                        dateFormatter.format(attendance.date ?? DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SpaceHeight(4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
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
                          if (attendance.isWeekend == true) ...[
                            const SpaceWidth(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Weekend',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                          if (attendance.isHoliday == true) ...[
                            const SpaceWidth(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Holiday',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SpaceHeight(16),
            const Divider(height: 1),
            const SpaceHeight(16),

            // Check In/Out Times
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    'Check In',
                    attendance.timeIn ?? '-',
                    Icons.login_rounded,
                    AppColors.green,
                  ),
                ),
                const SpaceWidth(16),
                Expanded(
                  child: _buildTimeInfo(
                    'Check Out',
                    attendance.timeOut ?? '-',
                    Icons.logout_rounded,
                    AppColors.red,
                  ),
                ),
              ],
            ),

            // Late/Early Leave Info
            if ((attendance.lateMinutes ?? 0) > 0 ||
                (attendance.earlyLeaveMinutes ?? 0) > 0) ...[
              const SpaceHeight(12),
              Row(
                children: [
                  if ((attendance.lateMinutes ?? 0) > 0)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SpaceWidth(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Late',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.red.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${attendance.lateMinutes} min',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if ((attendance.lateMinutes ?? 0) > 0 &&
                      (attendance.earlyLeaveMinutes ?? 0) > 0)
                    const SpaceWidth(12),
                  if ((attendance.earlyLeaveMinutes ?? 0) > 0)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timelapse_rounded,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SpaceWidth(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Early Leave',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.orange.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${attendance.earlyLeaveMinutes} min',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'on_time':
        return AppColors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return AppColors.red;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'on_time':
        return 'On Time';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      default:
        return status ?? 'Unknown';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'on_time':
        return Icons.check_circle_rounded;
      case 'late':
        return Icons.access_time_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

Widget _buildPresencePercentageCard(DateTime? selectedDate) {
  int getWorkingDaysInMonth() {
    final date = selectedDate ?? DateTime.now();

    final daysInMonth = DateTime(
      date.year,
      date.month + 1,
      0,
    ).day;

    int workingDays = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(
        date.year,
        date.month,
        day,
      );

      if (currentDate.weekday != DateTime.sunday) {
        workingDays++;
      }
    }

    return workingDays;
  }

  return _buildMainCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Persentase kehadiran (Bulanan)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF253B80),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const _CirclePercent(progress: 0.83),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5 dari ${getWorkingDaysInMonth()} hari hadir',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2A3C7A),
                    ),
                  ),
                  Text(
                    'Target mingguan 85%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7A86A8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.83,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFE6EAF4),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF4263F5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sedikit lagi! Pertahankan konsistensimu 💪',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF939DB8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildMainCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9EDF7)),
    ),
    child: child,
  );
}

class _CirclePercent extends StatelessWidget {
  final double progress;

  const _CirclePercent({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      height: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFE8ECF6),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4263F5)),
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243778),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildStatisticCard(DateTime? selectedDate) {
  final totalWorkingDays = getWorkingDaysInMonth(selectedDate);

  final absen = 1;
  final terlambat = 3;
  final hadir = totalWorkingDays - absen - terlambat;
  final hadirPercent = ((hadir / totalWorkingDays) * 100).round();

  final absenPercent = ((absen / totalWorkingDays) * 100).round();

  final terlambatPercent = ((terlambat / totalWorkingDays) * 100).round();
  return _buildMainCard(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Statistik kehadiran',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF253B80),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                title: 'Hadir',
                value: hadir.toString(),
                subtitle: '$hadirPercent%',
                icon: Icons.check_circle,
                iconColor: Color(0xFF19AF64),
                bgColor: Color(0xFFEAF8F0),
                subtitleColor: Color(0xFF1BAA62),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatItem(
                title: 'Absen',
                value: absen.toString(),
                subtitle: '$absenPercent%',
                icon: Icons.cancel,
                iconColor: Color(0xFFFF476C),
                bgColor: Color(0xFFFFEFF2),
                subtitleColor: Color(0xFFFF476C),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatItem(
                title: 'Terlambat',
                value: terlambat.toString(),
                subtitle: '$terlambatPercent%',
                icon: Icons.access_time_filled,
                iconColor: Color(0xFFF5A300),
                bgColor: Color(0xFFFFF5E2),
                subtitleColor: Color(0xFFF5A300),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatItem(
                title: 'Lembur',
                value: '2.5',
                subtitle: 'jam',
                icon: Icons.history,
                iconColor: Color(0xFF4263F5),
                bgColor: Color(0xFFEEF1FF),
                subtitleColor: Color(0xFF4263F5),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color subtitleColor;

  const _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF243778),
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF98A1BC),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: subtitleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

int getWorkingDaysInMonth(DateTime? selectedDate) {
  final date = selectedDate ?? DateTime.now();

  final daysInMonth = DateTime(
    date.year,
    date.month + 1,
    0,
  ).day;

  int workingDays = 0;

  for (int day = 1; day <= daysInMonth; day++) {
    final currentDate = DateTime(
      date.year,
      date.month,
      day,
    );

    if (currentDate.weekday != DateTime.sunday) {
      workingDays++;
    }
  }

  return workingDays;
}
