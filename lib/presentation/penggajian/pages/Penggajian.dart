import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/penggajian/pages/detail_penggajian.dart';
import 'package:flutter_absensi_app/presentation/penggajian/widgets/riwayat_gaji.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/gaji.dart';
import '../model/penggajian_model.dart';

final rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class RingkasanKerja extends StatefulWidget {
  const RingkasanKerja({super.key});

  @override
  State<RingkasanKerja> createState() => _RingkasanKerjaState();
}

class _RingkasanKerjaState extends State<RingkasanKerja> {

  late gajimodel gajiBulanIni;

  @override
  void initState() {
    super.initState();
    gajiBulanIni = gajiKaryawan[0]; 
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: const Color(0xBAE7E8EC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
              ],
            ),
            Positioned(
                top: screenHeight * 0.12,
                left: 16,
                right: 16,
                child: _gajiKaryawan()), // Menampilkan data dinamis sesuai state
            Positioned(
                top: screenHeight * 0.38,
                left: 16,
                right: 16,
                child: _ringkasanGaji()), // Menampilkan data dinamis sesuai state
            Positioned(
                top: screenHeight * 0.580,
                left: 16,
                right: 16,
                bottom: screenHeight * 0.003,
                child: _riwayatGaji()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 60),
      decoration: const BoxDecoration(
        color: Color(0xFF0A49B7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penggajian',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                    text: 'Hallo, ',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                TextSpan(
                    text: 'Karyawan 👋',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
          Text(
            'Berikut informasi gaji anda',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // UBAH MENJADI METHOD DI DALAM STATE AGAR BISA MENGAKSES VARIABEL `selectedGaji`
  Widget _gajiKaryawan() {
    DateTime now = DateTime.now();
  

    String bulanSekarang = DateFormat('MMMM yyyy', 'id_ID').format(now);


    final gajiBulanIni = gajiKaryawan.firstWhere(
      (gaji) => gaji.bulan.toLowerCase() == bulanSekarang.toLowerCase(),
      orElse: () => gajiKaryawan[0],
    );
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(50),
                spreadRadius: 1,
                blurRadius: 10)
          ]),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gaji Bersih Bulan ini',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gajiBulanIni.bulan, // DINAMIS
                    style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    rupiah.format(gajiBulanIni.totalGaji - gajiBulanIni.potongan), // DINAMIS
                    style: GoogleFonts.poppins(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        gajiBulanIni.tglBayar, // DINAMIS
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Dibayarkan',
                      style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    "assets/images/Wallet.png",
                    width: 95,
                    height: 95,
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPenggajianPage(gaji: gajiBulanIni),
                    ),
                  );
              print("Membuka Slip Gaji Bulan: ${gajiBulanIni.bulan}");
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFD8E4FD),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.feed_outlined,
                      color: Color(0xFF0151E7),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Lihat Slip Gaji",
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_right, size: 22)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _ringkasanGaji() {
    DateTime now = DateTime.now();

    String bulanSekarang = DateFormat('MMMM yyyy', 'id_ID').format(now);

    final gajiBulanIni = gajiKaryawan.firstWhere(
      (gaji) => gaji.bulan.toLowerCase() == bulanSekarang.toLowerCase(),
      orElse: () => gajiKaryawan[0],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ringkasan Bulan Ini",
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: [
              _buildTotalPenghasilan(
                  icon: Icons.north_east,
                  label: "Total Penghasilan",
                  subtitle: rupiah.format(gajiBulanIni.totalGaji), // DINAMIS
                  color: const Color(0x84BDF6D1)),
              _buildTotalPotongan(
                  icon: Icons.south_east,
                  label: "Total Potongan", // SUDAH DI-FIX BUKAN PENGHASILAN LAGI
                  subtitle: rupiah.format(gajiBulanIni.potongan), // DINAMIS
                  color: const Color(0x9CFFDBE2))
            ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFD7E4FF), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Color(0xFF0151E7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Rincian penghasilan, potongan, dan perhitungan lengkap bisa dilihat di slip gaji.",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 10),
                  maxLines: 2,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _riwayatGaji() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Riwayat Gaji",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: gajiKaryawan.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = gajiKaryawan[index];

              return RiwayatGajiCard(
                data: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPenggajianPage(gaji: item),
                    ),
                  );
              print("Membuka Slip Gaji Bulan: ${item.bulan}");
                  setState(() {
                    gajiBulanIni = item;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 5)
      ],
    );
  }

  // Tetapkan helper widget pendukung di bawah sini...
  Widget _buildTotalPenghasilan({required IconData icon, required String label, required String subtitle, required Color color}) {
     return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: const Color(0xFFC0F0D1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF1F8B4D), size: 25),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1F8B4D)))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTotalPotongan({required IconData icon, required String label, required String subtitle, required Color color}) {
     return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: const Color(0xFFFDD2DB), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.red, size: 25),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600))
            ],
          )
        ],
      ),
    );
  }
}