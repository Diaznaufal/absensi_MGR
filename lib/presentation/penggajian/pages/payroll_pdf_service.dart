import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/response/payroll_response_model.dart';
import 'package:intl/intl.dart';

class PayrollPdfService {
  static Future<void> generateSlipGaji(PayrollData detail) async {
    final pdf = pw.Document();

    final fontPoppins = await PdfGoogleFonts.poppinsRegular();
    final fontPoppinsBold = await PdfGoogleFonts.poppinsBold();

    final logoKantor =
        await imageFromAssetBundle('assets/images/logo_transparent.png');

    String formatBulan(String? rawDate) {
      if (rawDate == null || rawDate.isEmpty) return '';
      try {
        DateTime parseDate = DateTime.parse(rawDate);
        return DateFormat('MMMM yyyy', 'id_ID').format(parseDate);
      } catch (e) {
        return rawDate;
      }
    }

    String maskNip(String? nip) {
      if (nip == null || nip.isEmpty) return '-';
      // Membersihkan teks tambahan jika ada format bawaan ": " atau spasi
      String cleanNip = nip.replaceAll(RegExp(r'[:\s]'), '');
      if (cleanNip.length < 8) return cleanNip;

      int endMaskIndex = cleanNip.lastIndexOf('00');
      if (endMaskIndex <= 4) {
        endMaskIndex = cleanNip.length - 4;
      }

      String front = cleanNip.substring(0, 4);
      String back = cleanNip.substring(endMaskIndex);
      String bullets = '•' * (endMaskIndex - 4);

      return '$front$bullets$back';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(children: [
            pw.Positioned.fill(
                child: pw.Center(
                    child: pw.Opacity(
                        opacity: 0.1,
                        child: pw.Image(logoKantor, height: 350, width: 450)))),
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(-10, 5, -10, 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "SLIP GAJI KARYAWAN",
                      style: pw.TextStyle(font: fontPoppinsBold, fontSize: 18),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                      "Periode: ${formatBulan(detail.periodeGajian)}",
                      style: pw.TextStyle(font: fontPoppins, fontSize: 11),
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Divider(thickness: 1.5),
                  pw.SizedBox(height: 10),
                  pw.Text("DATA KARYAWAN",
                      style: pw.TextStyle(font: fontPoppinsBold, fontSize: 12)),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Nama: ${detail.karyawan?.name ?? '-'}",
                                style: pw.TextStyle(
                                    font: fontPoppins, fontSize: 11)),
                            pw.SizedBox(height: 4),
                            pw.Text("NIP: ${maskNip(detail.karyawan?.nip)}",
                                style: pw.TextStyle(
                                    font: fontPoppins, fontSize: 11)),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Divisi: ${detail.karyawan?.divisi ?? '-'}",
                                style: pw.TextStyle(
                                    font: fontPoppins, fontSize: 11)),
                            pw.SizedBox(height: 4),
                            pw.Text(
                                "Posisi: ${detail.karyawan?.jabatan ?? '-'}",
                                style: pw.TextStyle(
                                    font: fontPoppins, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Kolom Kiri: List Penghasilan Dinamis (.map)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("PENGHASILAN",
                                style: pw.TextStyle(
                                    font: fontPoppinsBold,
                                    fontSize: 11,
                                    color: PdfColors.green)),
                            pw.SizedBox(height: 6),

                            // Melakukan mapping objek dari List<PayrollItem> model Anda
                            if (detail.penghasilan != null)
                              ...detail.penghasilan!.map((item) =>
                                  _buildRincianRow(item.label ?? "-",
                                      item.formatted ?? "Rp 0", fontPoppins)),

                            pw.Divider(thickness: 0.5),
                            _buildRincianRow(
                                "Total Penghasilan",
                                detail.ringkasan?.totalPenghasilanFormatted ??
                                    "Rp 0",
                                fontPoppinsBold),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 30), // Jarak pemisah antar kolom

                      // Kolom Kanan: List Potongan Dinamis (.map)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("POTONGAN",
                                style: pw.TextStyle(
                                    font: fontPoppinsBold,
                                    fontSize: 11,
                                    color: PdfColors.red)),
                            pw.SizedBox(height: 6),
                            if (detail.potongan != null)
                              ...detail.potongan!.map((item) {
                                String labelText = item.label ?? "-";
                                // Mencocokkan data totalAbsen dari objek Kehadiran di model
                                if (labelText.toLowerCase().contains('absen') ==
                                        true &&
                                    detail.kehadiran != null) {
                                  labelText +=
                                      ' (${detail.kehadiran!.totalAbsen ?? 0} Hari)';
                                }
                                return _buildRincianRow(labelText,
                                    item.formatted ?? "Rp 0", fontPoppins);
                              }),
                            pw.Divider(thickness: 0.5),
                            _buildRincianRow(
                                "Total Potongan",
                                detail.ringkasan?.totalPotonganFormatted ??
                                    "Rp 0",
                                fontPoppinsBold),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1.5),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("GAJI BERSIH",
                          style: pw.TextStyle(
                              font: fontPoppinsBold, fontSize: 13)),
                      pw.Text(
                        detail.ringkasan?.gajiBersihFormatted ?? "Rp 0",
                        style: pw.TextStyle(
                            font: fontPoppinsBold,
                            fontSize: 15,
                            color: PdfColors.blue800),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ]);
        },
      ),
    );

    // Membuka Print & Save Preview bawaan HP
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Slip_Gaji_${detail.monthLabel?.replaceAll(' ', '_') ?? 'Karyawan'}.pdf',
    );
  }

  // Generator Baris Rincian Teks Komponen
  static pw.Widget _buildRincianRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }
}
