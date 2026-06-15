import 'package:flutter/material.dart';

import 'package:flutter_absensi_app/presentation/pengaduan/model/timeline_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TimelineCard extends StatelessWidget {
  final TimelineData timeline;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.timeline,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      timeline.isActive ? timeline.color : Colors.grey.shade300,
                  border: Border.all(
                    color: timeline.isActive
                        ? timeline.color
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: timeline.isActive
                        ? timeline.color
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeline.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: timeline.isActive ? timeline.color : Colors.grey,
                    ),
                  ),
                  Text(
                    timeline.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat(
                      'dd-MM-yyyy • HH:mm',
                    ).format(timeline.date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
