import 'package:flutter/material.dart';
import '../model/penggajian_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class DetailPenggajianPage extends StatelessWidget {
  final gajimodel gaji;

  const DetailPenggajianPage({super.key, required this.gaji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF6EFEFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 22),
            ),
            const SizedBox(width: 20),
            Text(
              'Slip Gaji',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body:
          // Konten Scrollable
          SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            16, 16, 16, 16), // Padding bawah disisakan untuk button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderPeriode(),
            const SizedBox(height: 16),
            _buildDataKaryawan(),
            const SizedBox(height: 20),
            _buildCardPenghasilan(),
            const SizedBox(height: 20),
            _buildCardPotongan(),
            const SizedBox(height: 20),
            _buildCardPerhitunganBersih(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {}, // Action download PDF
                icon: const Icon(Icons.download, color: Colors.blue),
                label: Text(
                  'Download Slip Gaji (PDF)',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Button Download melayang di bawah tunggal
    );
  }

  // 1. Bagian Bulan & Tanggal Bayar
  Widget _buildHeaderPeriode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // posisi bayangan
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gaji.bulan, // Pakai data dari model
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dibayarkan pada ${gaji.tglBayar}',
                    style:
                        GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFFBFDBFE).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'Gaji Bersih',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  rupiah.format(
                      gaji.totalGaji - gaji.potongan), // Sesuai model/data
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D4ED8)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 2. Widget Gaji Bersih Biru Atas

  // 3. Widget Detail Data Karyawan
  Widget _buildDataKaryawan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // posisi bayangan
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Karyawan',
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildRowDetail('NIP',
              ':  ********468'), // Sesuaikan key property model Anda jika ada
          _buildRowDetail('Nama', 'Diaz Naufal Ruswana'),
          _buildRowDetail('Divisi', 'IT'),
          _buildRowDetail('Posisi', 'Front End Developer'),
        ],
      ),
    );
  }

  // 4. Widget Bagian Penghasilan
  Widget _buildCardPenghasilan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // posisi bayangan
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.wallet_rounded,
                          color: Colors.green, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('PENGHASILAN',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRowDetail('Gaji Pokok', rupiah.format(gaji.totalGaji)),
                _buildRowDetail('Uang Makan', 'Rp 0'),
                _buildRowDetail('Lembur', 'Rp 0'),
                _buildRowDetail('Bonus', 'Rp 0'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Penghasilan',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
                Text(rupiah.format(gaji.totalGaji),
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 5. Widget Bagian Potongan
  Widget _buildCardPotongan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // posisi bayangan
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.red, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text('POTONGAN',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRowDetail('Absen', rupiah.format(gaji.potongan),
                    subLeft: '(Rp 30.000 x 5)'),
                _buildRowDetail('Kasbon', 'Rp 0'),
                _buildRowDetail('Keterlambatan', 'Rp 0'),
                _buildRowDetail('Uang Makan', 'Rp 0'),
                _buildRowDetail('PPH', 'Rp 0'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Potongan',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red)),
                Text(rupiah.format(gaji.potongan),
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.red)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 6. Widget Perhitungan Gaji Bersih (Paling Bawah)
  Widget _buildCardPerhitunganBersih() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // posisi bayangan
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERHITUNGAN GAJI BERSIH',
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          _buildRowDetail('Total Penghasilan', rupiah.format(gaji.totalGaji),
              isBoldLeft: true),
          _buildRowDetail('- Total Potongan', rupiah.format(gaji.potongan),
              colorRight: Colors.red),
          _buildRowDetail('- PPH', 'Rp 0', colorRight: Colors.red),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gaji Bersih',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[800])),
              Text(rupiah.format(gaji.totalGaji - gaji.potongan),
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue[700])),
            ],
          )
        ],
      ),
    );
  }

  // Helper Widget untuk Baris Detail (Key-Value Row)
  Widget _buildRowDetail(
    String leftText,
    String rightText, {
    String? subLeft,
    Color? colorRight,
    bool isBoldLeft = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                leftText,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: isBoldLeft ? FontWeight.w600 : FontWeight.w400),
              ),
              if (subLeft != null) ...[
                const SizedBox(width: 8),
                Text(
                  subLeft,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[500]),
                ),
              ]
            ],
          ),
          Text(
            rightText,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorRight ?? Colors.black),
          ),
        ],
      ),
    );
  }
}
