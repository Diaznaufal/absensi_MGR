import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart'; // 👈 1. IMPORT HELPER
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
      final String idAttendance =
          widget.attendanceItem.idAttendance?.toString() ?? '';

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
            detailData = successData;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openMapApp(double lat, double lng) async {
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Tidak dapat membuka aplikasi peta.");
      }
    } catch (e) {
      debugPrint("🚨 Gagal membuka maps: $e");
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
        final DateTime tanggalDasar =
            DateTime.parse(detailData!.tanggalMasuk!);
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
        toolbarHeight: 56.h,
        backgroundColor: const Color(0xFF0A49B7),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child:
              Icon(Icons.arrow_back_ios_new, size: 20.r, color: Colors.white),
        ),
        title: Text(
          'Detail Absensi',
          style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  children: [
                    _informasiKehadiran(),
                    SizedBox(height: 12.h),
                    _rincianWaktu(),
                    SizedBox(height: 12.h),
                    _verifikasiFace(),
                    SizedBox(height: 12.h),
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
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Kehadiran',
                          style: GoogleFonts.poppins(fontSize: 11.sp)),
                      SizedBox(height: 4.h),
                      Text(
                        '◉ $statusLabel',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: isOntime ? Colors.green : Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                VerticalDivider(width: 24.w, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Keterlambatan',
                          style: GoogleFonts.poppins(fontSize: 11.sp)),
                      SizedBox(height: 4.h),
                      Text(
                        isOntime ? '0 Menit' : '$selisihMenit Menit',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
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
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: const Color(0xFF0A49B7),
                      child: Text('IN',
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    SizedBox(height: 4.h),
                    Text('Check In',
                        style: GoogleFonts.poppins(fontSize: 11.sp)),
                    Text(
                      detailData?.checkIn?.jamMasuk ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.h),
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
                      radius: 18.r,
                      backgroundColor: const Color(0xFF0A49B7),
                      child: Text('OUT',
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    SizedBox(height: 4.h),
                    Text('Check Out',
                        style: GoogleFonts.poppins(fontSize: 11.sp)),
                    Text(
                      detailData?.checkOut?.jamKeluar ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp, fontWeight: FontWeight.w600),
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
    final double imgSize = 135.w;

    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/scanperson.svg',
                  width: 20.r, height: 20.r),
              SizedBox(width: 8.w),
              Text('Verifikasi Face Recognition',
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'IN',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: photoIn != null && photoIn.isNotEmpty
                        ? Image.network(
                            photoIn,
                            height: imgSize,
                            width: imgSize,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholderImage(imgSize),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'OUT',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: photoOut != null && photoOut.isNotEmpty
                        ? Image.network(
                            photoOut,
                            height: imgSize,
                            width: imgSize,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholderImage(imgSize),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(double size) {
    return Image.asset(
      'assets/images/orang.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }

  // 🔄 2. WIDGET LOKASI KARYAWAN DENGAN VALIDASI & VISUALISASI POLYGON
  Widget _lokasiKaryawan() {
    // Ambil string polygon dari productLocation
    final String? polygonRaw = detailData?.productLocation?.polygon;
    final List<List<double>> rawPolygonPoints =
        RadiusCalculate.parsePolygon(polygonRaw);

    // Konversi ke List<LatLng> untuk FlutterMap
    final List<LatLng> polygonLatLngs = rawPolygonPoints
        .map((point) => LatLng(point[0], point[1]))
        .toList();

    final double latIn =
        double.tryParse(detailData?.checkIn?.latitude ?? '0') ?? -6.917464;
    final double lngIn =
        double.tryParse(detailData?.checkIn?.longitude ?? '0') ?? 107.619123;

    final double latOut =
        double.tryParse(detailData?.checkOut?.latitude ?? '0') ?? -6.917464;
    final double lngOut =
        double.tryParse(detailData?.checkOut?.longitude ?? '0') ?? 107.619123;

    // Cek apakah koordinat IN / OUT berada di dalam polygon
    final bool isInsideIn = rawPolygonPoints.isNotEmpty
        ? RadiusCalculate.isPointInPolygon(latIn, lngIn, rawPolygonPoints)
        : true;

    final bool isInsideOut = rawPolygonPoints.isNotEmpty
        ? RadiusCalculate.isPointInPolygon(latOut, lngOut, rawPolygonPoints)
        : true;

    final bool hasCheckedOut = detailData?.checkOut?.jamKeluar != null;

    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_pin, size: 20.r),
              SizedBox(width: 8.w),
              Text('Lokasi (GPS)',
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12.h),

          // CHECK IN (IN)
          _buildMapLocationRow(
            label: ' I\nN',
            lat: latIn,
            lng: lngIn,
            isInside: isInsideIn,
            polygonLatLngs: polygonLatLngs,
            isAvailable: true,
            onTap: () => _openMapApp(latIn, lngIn),
          ),
          SizedBox(height: 16.h),

          // CHECK OUT (OUT)
          _buildMapLocationRow(
            label: 'O\nU\nT',
            lat: latOut,
            lng: lngOut,
            isInside: isInsideOut,
            polygonLatLngs: polygonLatLngs,
            isAvailable: hasCheckedOut,
            onTap: hasCheckedOut ? () => _openMapApp(latOut, lngOut) : null,
          ),
        ],
      ),
    );
  }

  // 🔄 3. RENDER BARIS MAP + AREA POLYGON
  Widget _buildMapLocationRow({
    required String label,
    required double lat,
    required double lng,
    required bool isInside,
    required List<LatLng> polygonLatLngs,
    required bool isAvailable,
    required VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10.w),
        InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 80.w,
            height: 80.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 15.0,
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jagoflutter.hr',
                  ),
                  // Render polygon jika data koordinat tersedia
                  if (polygonLatLngs.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: polygonLatLngs,
                          color: Colors.blue.withOpacity(0.2),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 24.r,
                        height: 24.r,
                        child: Icon(Icons.location_on,
                            color: isAvailable
                                ? (isInside ? Colors.blue : Colors.red)
                                : Colors.grey,
                            size: 24.r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Koordinat',
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: Colors.grey)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isAvailable ? '$lat, $lng' : '-',
                        style: GoogleFonts.poppins(fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Area',
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp, color: Colors.grey)),
                        Text(
                          isAvailable
                              ? (isInside ? 'Dalam Area' : 'Luar Area')
                              : '-',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? (isInside ? Colors.green : Colors.red)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF0A49B7)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined,
                                color: Colors.white, size: 14.r),
                            SizedBox(width: 4.w),
                            Text(
                              'Peta',
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 10.sp),
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
    );
  }
}

Widget _buildMainCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: const Color(0xFFE9EDF7)),
    ),
    child: child,
  );
}