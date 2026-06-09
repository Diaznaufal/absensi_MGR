import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceHistoryCard extends StatelessWidget {
  final String day;
  final String date;
  final String checkIn;
  final String checkOut;
  final AttendanceStatus status;
  final String? note;

  const AttendanceHistoryCard({
    super.key,
    required this.day,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7ECF5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: config.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$day, $date',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF243778),
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check In',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF9AA3BD),
                          ),
                        ),
                        Text(
                          '$checkIn',
                          style: GoogleFonts.poppins(
                              fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check Out',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF9AA3BD),
                          ),
                        ),
                        Text(
                          '$checkOut',
                          style: GoogleFonts.poppins(
                              fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                config.label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: config.color,
                ),
              ),
              if (note != null && note!.isNotEmpty)
                Text(
                  note!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF9AA3BD),
                  ),
                ),
            ],
          ),
          SizedBox(
            width: 8,
          ),
          Icon(
            Icons.keyboard_arrow_right,
            size: 20,
          )
        ],
      ),
    );
  }

  _AttendanceStatusConfig _statusConfig(
    AttendanceStatus status,
  ) {
    switch (status) {
      case AttendanceStatus.present:
        return const _AttendanceStatusConfig(
          label: 'Hadir',
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
          label: 'Absen',
          color: Color(0xFFFF476C),
          backgroundColor: Color(0xFFFFEFF2),
          icon: Icons.cancel,
        );

      case AttendanceStatus.overtime:
        return const _AttendanceStatusConfig(
          label: 'Lembur',
          color: Color(0xFF4263F5),
          backgroundColor: Color(0xFFEEF1FF),
          icon: Icons.history,
        );
    }
  }
}

enum AttendanceStatus {
  present,
  late,
  absent,
  overtime,
}

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
