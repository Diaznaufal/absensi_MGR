import 'package:flutter/material.dart';
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  color: const Color(0xC2D8E4FD),
                  borderRadius: BorderRadius.circular(5)),
              child: const Icon(
                Icons.feed_outlined,
                color: Color(0xFF0151E7),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatBulan(data.monthLabel),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    data.tanggalGajianLabel ?? "-",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.gajiBersihFormatted ?? "Rp 0",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F8B4D),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_right,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
