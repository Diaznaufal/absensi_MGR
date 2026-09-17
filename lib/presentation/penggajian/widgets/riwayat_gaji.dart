import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/response/payroll_response_model.dart';
import 'package:intl/intl.dart';

class RiwayatGajiCard extends StatelessWidget {
  final PayrollHistoryItem data;
  final VoidCallback onTap;

  const RiwayatGajiCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  String formatBulan(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      DateTime parseDate = DateTime.parse(rawDate);
      return DateFormat('MMMM yyyy', 'id_ID').format(parseDate);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              width: 35.r,
              height: 35.r,
              decoration: BoxDecoration(
                color: const Color(0xC2D8E4FD),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(
                Icons.feed_outlined,
                color: const Color(0xFF0151E7),
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatBulan(data.monthLabel),
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data.tanggalGajianLabel ?? "-",
                    style: GoogleFonts.poppins(
                      fontSize: 10.5.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.gajiBersihFormatted ?? "Rp 0",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F8B4D),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.keyboard_arrow_right,
              size: 20.r,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}
