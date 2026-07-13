import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/history_response_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';
import 'package:latlong2/latlong.dart';

class DetailHistoryPage extends StatefulWidget {
  // Menerima data lemparan langsung dari card riwayat di halaman depan
  final dynamic attendanceItem;

  const DetailHistoryPage({Key? key, required this.attendanceItem})
      : super(key: key);

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  final _datasoource = AttendanceRemoteDatasource();
  HistoryDetailModel? detailData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetailAbsensi();
  }

  Future<void> _fetchDetailAbsensi() async {
    try {
      // Pastikan key lemparan dari card depan namanya 'idAttendance' atau sesuaikan dengan objek asli kamu[cite: 6]
      final String idAttendance =
          widget.attendanceItem.idAttendance?.toString() ?? '';

      // Panggil fungsi getHistoryDetail yang sudah kamu perbaiki di datasource[cite: 7]
      final result =
          await _datasoource.getHistoryDetail(idAttendance: idAttendance);

      result.fold(
        (failureMessage) {
          setState(() {
            _isLoading = false;
          });
        },
        (successData) {
          setState(() {
            detailData = successData; // Set data ke model UI[cite: 6]
            _isLoading = false; // Matikan loading[cite: 6]
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // <-- TAMBAHKAN METODE INI DI BAWAH _calculateLate()
  Future<void> _openMapApp(double lat, double lng) async {
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        print("Tidak dapat membuka aplikasi peta.");
      }
    } catch (e) {
      print("🚨 Gagal membuka maps: $e");
    }
  }

  int _calculateLate() {
    final checkIn = detailData?.checkIn;
    final workShift = detailData?.workshift;

    if (checkIn?.jamMasuk != null &&
        workShift?.clockIn != null &&
        checkIn!.jamMasuk!.isNotEmpty &&
        workShift!.clockIn!.isNotEmpty) {
      try {
        final DateTime tanggalDasar = DateTime.parse(detailData!.tanggalMasuk!);
        final splitJamMasuk = checkIn.jamMasuk!.split(':');
        final splitClockIn = workShift.clockIn!.split(':');

        final waktuCheckIn = DateTime(
            tanggalDasar.year,
            tanggalDasar.month,
            tanggalDasar.day,
            int.parse(splitJamMasuk[0]),
            int.parse(splitJamMasuk[1]));

        final waktuJadwalIn = DateTime(
            tanggalDasar.year,
            tanggalDasar.month,
            tanggalDasar.day,
            int.parse(splitClockIn[0]),
            int.parse(splitClockIn[1]));

        final selisiMenit = waktuCheckIn.difference(waktuJadwalIn).inMinutes;

        return selisiMenit > 0 ? selisiMenit : 0;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xEEF9FAFB),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF0A49B7),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 22, color: Colors.white),
        ),
        title: Text(
          'Detail Absensi',
          style: GoogleFonts.poppins(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _informasiKehadiran(),
                    const SizedBox(height: 16),
                    _rincianWaktu(),
                    const SizedBox(height: 16),
                    _verifikasiFace(),
                    const SizedBox(height: 16),
                    _lokasiKaryawan()
                  ],
                ),
              ),
      ),
    );
  }

  Widget _informasiKehadiran() {
    final checkIn = detailData?.checkIn;

    final bool isOntime = checkIn?.timeManagement ?? true;
    final String statusLabel = checkIn?.timeManagementLabel ?? '';

    final selisihMenit = _calculateLate();
    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Kehadiran',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Kehadiran',
                          style: GoogleFonts.poppins(fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(
                        '◉ $statusLabel',
                        style: GoogleFonts.poppins(
                          color: isOntime ? Colors.green : Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                const VerticalDivider(width: 40, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Keterlambatan',
                          style: GoogleFonts.poppins(fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(
                        isOntime
                            ? '0 Menit'
                            : '$selisihMenit Menit', // Menampilkan status keterlambatan dinamis
                        style: GoogleFonts.poppins(
                          color: isOntime ? Colors.green : Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _rincianWaktu() {
    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Waktu',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF0A49B7),
                      child: Text('IN',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 5),
                    Text('Check In', style: GoogleFonts.poppins(fontSize: 12)),
                    Text(
                      detailData?.checkIn?.jamMasuk ??
                          '-', // Mengambil jam masuk dinamis per index
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 17),
                    child: FDottedLine(
                      color: Colors.grey,
                      width: double.infinity,
                      strokeWidth: 2.0,
                      space: 3.0,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF0A49B7),
                      child: Text('OUT',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 5),
                    Text('Check Out', style: GoogleFonts.poppins(fontSize: 12)),
                    Text(
                      detailData?.checkOut?.jamKeluar ??
                          '-', // Mengambil jam keluar dinamis per index
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifikasiFace() {
    final String? photoIn = detailData?.checkIn?.photoUrl;
    final String? photoOut = detailData?.checkOut?.photoUrl;
    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/scanperson.svg'),
              const SizedBox(width: 10),
              Text('Verifikasi Face Recognition',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'IN',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: photoIn != null && photoIn.isNotEmpty
                        ? Image.network(
                            photoIn,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholderImage(),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'OUT',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: photoOut != null && photoOut.isNotEmpty
                        ? Image.network(
                            photoOut,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholderImage(),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/orang.png',
      width: 150,
      height: 150,
      fit: BoxFit.cover,
    );
  }

  Widget _lokasiKaryawan() {
    final double officeLat =
        double.tryParse(detailData?.productLocation?.latitude ?? '') ?? 0.0;
    final double officeLng =
        double.tryParse(detailData?.productLocation?.longitude ?? '') ?? 0.0;

    final double latIn =
        double.tryParse(detailData?.checkIn?.latitude ?? '0') ?? -6.917464;
    final double lngIn =
        double.tryParse(detailData?.checkIn?.longitude ?? '0') ?? 107.619123;

    final double latOut =
        double.tryParse(detailData?.checkOut?.latitude ?? '0') ?? -6.917464;
    final double lngOut =
        double.tryParse(detailData?.checkOut?.longitude ?? '0') ?? 107.619123;

    double distanceIn = 0.0;
    if (officeLat != 0.0 && latIn != 0.0) {
      distanceIn =
          Geolocator.distanceBetween(officeLat, officeLng, latIn, lngIn);
    }

    double distanceOut = 0.0;
    if (officeLat != 0.0 && latOut != 0.0) {
      distanceOut =
          Geolocator.distanceBetween(officeLat, officeLng, latOut, lngOut);
    }

    // Pengecekan apakah user sudah absen pulang atau belum
    final bool hasCheckedOut = detailData?.checkOut?.jamKeluar != null;

    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_pin),
              const SizedBox(width: 10),
              Text('Lokasi (GPS)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),

          // ==================== CHECK IN (IN) ====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' I\nN',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _openMapApp(latIn, lngIn), // <-- TAMBAHKAN PETA IN
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latIn, lngIn),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.jagoflutter.hr',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latIn, lngIn),
                              width: 30,
                              height: 30,
                              child: const Icon(Icons.location_on,
                                  color: Colors.blue, size: 30),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Koordinat\n',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey)),
                            TextSpan(
                                text: '$latIn, $lngIn',
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        'Jarak Kantor\n', // Umat diganti biar pas keterangannya
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: Colors.grey)),
                                TextSpan(
                                    text:
                                        '${distanceIn.toStringAsFixed(0)} Meter', // Ubah toFixed jadi 0 biar rapi bulat
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _openMapApp(
                                latIn, lngIn), // <-- TAMBAHKAN TOMBOL IN
                            child: Container(
                              width: 115,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A49B7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.map_outlined,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lihat di Peta',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // ==================== CHECK OUT (OUT) ====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'O\nU\nT',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: hasCheckedOut
                    ? () => _openMapApp(latOut, lngOut)
                    : null, // <-- TAMBAHKAN PETA OUT
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latOut, lngOut),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.MGR.hris',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latOut, lngOut),
                              width: 30,
                              height: 30,
                              child: Icon(Icons.location_on,
                                  color:
                                      hasCheckedOut ? Colors.blue : Colors.grey,
                                  size: 30),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Koordinat\n',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey)),
                            TextSpan(
                                text: hasCheckedOut
                                    ? '$latOut, $lngOut'
                                    : '-', // Tampilkan strip jika belum checkout
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Jarak Kantor\n',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: Colors.grey)),
                                TextSpan(
                                    text: hasCheckedOut
                                        ? '${distanceOut.toStringAsFixed(0)} Meter'
                                        : '-', // Tampilkan strip jika belum checkout
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: hasCheckedOut
                                ? () => _openMapApp(latOut, lngOut)
                                : null, // <-- TAMBAHKAN TOMBOL OUT
                            child: Container(
                              width: 115,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: hasCheckedOut
                                    ? const Color(0xFF0A49B7)
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.map_outlined,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lihat di Peta',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

Widget _buildMainCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9EDF7)),
    ),
    child: child,
  );
}
