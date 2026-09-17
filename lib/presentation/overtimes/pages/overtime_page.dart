import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      return hours.toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

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
                    content: Text(
                      response.message ?? 'Lembur berhasil diajukan',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    backgroundColor: AppColors.green,
                  ),
                );
                _refreshData();
              },
              error: (message) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message, style: TextStyle(fontSize: 12.sp)),
                    backgroundColor: AppColors.red,
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF0A49B7),
                      onRefresh: _refreshData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16.w : 12.w,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 12.h),
                            _buildOvertimeActions(context),
                            SizedBox(height: 20.h),
                            _buildHistorySection(context),
                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lembur',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Kelola riwayat lembur Anda',
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
    );
  }

  Widget _buildOvertimeActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A49B7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.access_time_filled_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Lembur',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Silakan ajukan rencana lembur Anda melalui tombol di bawah.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1),
          SizedBox(height: 14.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A49B7).withOpacity(0.08),
              foregroundColor: const Color(0xFF0A49B7),
              elevation: 0,
              minimumSize: Size(double.infinity, 44.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
                side: const BorderSide(color: Color(0xFF0A49B7), width: 1.2),
              ),
            ),
            icon: Icon(Icons.edit_calendar_rounded, size: 18.r),
            label: Text(
              'Ajukan Lembur',
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (bCtx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(bCtx),
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
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(bCtx).viewInsets.bottom + 20.h,
                  left: 16.w,
                  right: 16.w,
                  top: 14.h,
                ),
                child: SafeArea(
                  top: false,
                  child: StatefulBuilder(
                    builder: (context, setModalState) => SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 36.w,
                              height: 4.h,
                              margin: EdgeInsets.only(bottom: 14.h),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          Text(
                            'Form Lembur',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          TextField(
                            controller: dateController,
                            readOnly: true,
                            style: GoogleFonts.poppins(fontSize: 12.sp),
                            decoration: InputDecoration(
                              labelText: 'Tanggal Lembur',
                              labelStyle:
                                  GoogleFonts.poppins(fontSize: 11.5.sp),
                              suffixIcon: Icon(Icons.calendar_today_rounded,
                                  size: 18.r),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: startController,
                                  readOnly: true,
                                  style: GoogleFonts.poppins(fontSize: 12.sp),
                                  decoration: InputDecoration(
                                    labelText: 'Jam Mulai *',
                                    labelStyle:
                                        GoogleFonts.poppins(fontSize: 11.5.sp),
                                    suffixIcon: Icon(
                                      Icons.access_time_rounded,
                                      size: 18.r,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setModalState(() => startController.text =
                                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: TextField(
                                  controller: endController,
                                  readOnly: true,
                                  style: GoogleFonts.poppins(fontSize: 12.sp),
                                  decoration: InputDecoration(
                                    labelText: 'Jam Selesai *',
                                    labelStyle:
                                        GoogleFonts.poppins(fontSize: 11.5.sp),
                                    suffixIcon: Icon(
                                      Icons.access_time_rounded,
                                      size: 18.r,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setModalState(() => endController.text =
                                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          TextField(
                            controller: reasonController,
                            maxLines: 2,
                            style: GoogleFonts.poppins(fontSize: 12.sp),
                            decoration: InputDecoration(
                              labelText: 'Deskripsi / Alasan Lembur *',
                              labelStyle:
                                  GoogleFonts.poppins(fontSize: 11.5.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.all(12.r),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 46.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A49B7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (startController.text.isNotEmpty &&
                                    endController.text.isNotEmpty &&
                                    reasonController.text.isNotEmpty) {
                                  final calculatedSpend = _calculateTimeSpend(
                                    startController.text,
                                    endController.text,
                                  );

                                  context
                                      .read<CreateOvertimeBloc>()
                                      .add(CreateOvertimeEvent.submit(
                                        date: dateController.text,
                                        startTime: startController.text,
                                        endTime: endController.text,
                                        timeSpend: calculatedSpend,
                                        description: reasonController.text,
                                      ));
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Ajukan Lembur',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<GetOvertimesBloc, GetOvertimesState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (message) => Center(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
              success: (response) {
                final history = response.data ?? [];
                if (history.isEmpty) {
                  return _buildNoDataHistory();
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) =>
                      _buildOvertimeCard(history[index]),
                );
              },
              orElse: () => _buildNoDataHistory(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoDataHistory() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: Colors.orange, size: 40.r),
          SizedBox(height: 12.h),
          Text(
            'No Overtime Records',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'You haven\'t submitted any overtime yet',
            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeCard(Overtime overtime) {
    final statusColor = _getOvertimeStatusColor(overtime.statusLabel);
    final statusLabel = overtime.statusLabel ?? 'Pending';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
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
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getOvertimeStatusIcon(overtime.statusLabel),
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overtime.tanggal ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10.r),
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
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Start Time',
                  overtime.start ?? '-',
                  Icons.login_rounded,
                  AppColors.green,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildTimeInfo(
                  'End Time',
                  overtime.end ?? '-',
                  Icons.logout_rounded,
                  AppColors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Total Durasi',
            '${overtime.timeSpend ?? '0'} Jam',
            Icons.timelapse_rounded,
          ),
          if (overtime.description != null &&
              overtime.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              'Deskripsi',
              overtime.description!,
              Icons.notes_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.r),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5.sp,
                    color: color.withOpacity(0.7),
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
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
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.light.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 14.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5.sp,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
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

  Color _getOvertimeStatusColor(String? statusLabel) {
    switch (statusLabel?.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return AppColors.green;
      case 'ditolak':
      case 'rejected':
        return AppColors.red;
      default:
        return Colors.orange;
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
