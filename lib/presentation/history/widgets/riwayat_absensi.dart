import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryCard extends StatelessWidget {
  final String day;
  final String date;
  final String checkIn;
  final String checkOut;
  final AttendanceStatus status;
  final int? lateMinutes;
  final VoidCallback ontap;

  const AttendanceHistoryCard({
    super.key,
    required this.day,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.lateMinutes,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    DateTime parsedDate = DateTime.tryParse(date) ?? DateTime.now();

    String formatDay = DateFormat('EEEE', "id_ID").format(parsedDate);
    String formatDate = DateFormat('d MMMM yyyy', 'id_ID').format(parsedDate);

    String cleanCheckIn =
        checkIn.length >= 5 ? checkIn.substring(0, 5) : checkIn;
    String cleanCheckOut =
        checkOut.length >= 5 ? checkOut.substring(0, 5) : checkOut;

    return InkWell(
      onTap: ontap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE7ECF5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: config.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: 20.r,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$formatDay, $formatDate',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF243778),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check In',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: const Color(0xFF9AA3BD),
                            ),
                          ),
                          Text(
                            cleanCheckIn,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 14.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check Out',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: const Color(0xFF9AA3BD),
                            ),
                          ),
                          Text(
                            cleanCheckOut,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    config.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: config.color,
                    ),
                  ),
                ),
                if ((lateMinutes ?? 0) > 0)
                  Text(
                    '$lateMinutes mnt',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  _AttendanceStatusConfig _statusConfig(
    AttendanceStatus status,
  ) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const _AttendanceStatusConfig(
          label: 'On time',
          color: Color(0xFF19AF64),
          backgroundColor: Color(0xFFEAF8F0),
          icon: Icons.check_circle,
        );

      case AttendanceStatus.late:
        return const _AttendanceStatusConfig(
          label: 'Terlambat',
          color: Color(0xFFF5A300),
          backgroundColor: Color(0xFFFFF5E2),
          icon: Icons.access_time_filled,
        );

      case AttendanceStatus.absent:
        return const _AttendanceStatusConfig(
          label: 'Tidak Hadir',
          color: Color(0xFFFF476C),
          backgroundColor: Color(0xFFFFEFF2),
          icon: Icons.cancel,
        );
      case AttendanceStatus.cuti:
        return const _AttendanceStatusConfig(
          label: 'Cuti',
          color: Color(0xFFFF476C),
          backgroundColor: Color(0xFFFFEFF2),
          icon: Icons.cancel,
        );
      case AttendanceStatus.dayoff:
      case AttendanceStatus.libur:
        return const _AttendanceStatusConfig(
          label: 'Hari Libur',
          color: Color(0xFFFF476C),
          backgroundColor: Color(0xFFFFEFF2),
          icon: Icons.cancel,
        );
      case AttendanceStatus.minggu:
        return const _AttendanceStatusConfig(
          label: 'Minggu',
          color: Color(0xFFFF476C),
          backgroundColor: Color(0xFFFFEFF2),
          icon: Icons.cancel,
        );
    }
  }
}

enum AttendanceStatus { onTime, late, absent, cuti, dayoff, libur, minggu }

class _AttendanceStatusConfig {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const _AttendanceStatusConfig({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });
}
