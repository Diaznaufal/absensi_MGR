// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attandences/scanner_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_success_page.dart';

import 'face_detector_checkin_page.dart';

class AttendanceResultPage extends StatefulWidget {
  final bool isCheckin;
  final bool isMatch;
  final String attendanceType;
  final double? latitude;
  final double? longitude;

  const AttendanceResultPage({
    super.key,
    required this.isCheckin,
    required this.isMatch,
    required this.attendanceType,
    this.latitude,
    this.longitude,
  });

  @override
  State<AttendanceResultPage> createState() => _RecognitionResultPageState();
}

class _RecognitionResultPageState extends State<AttendanceResultPage>
    with SingleTickerProviderStateMixin {
  double? latitude;
  double? longitude;
  bool isLoadingLocation = true;
  String? locationError;
  bool isWithinRadius = false;
  double distance = 0.0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Use passed lat/long or get current position
    if (widget.latitude != null && widget.longitude != null) {
      latitude = widget.latitude;
      longitude = widget.longitude;
      isLoadingLocation = false;
    } else {
      getCurrentPosition();
    }

    // Get company data to validate radius
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getCurrentPosition() async {
    try {
      setState(() {
        isLoadingLocation = true;
        locationError = null;
      });

      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            isLoadingLocation = false;
            locationError = 'Location service is disabled';
          });
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            isLoadingLocation = false;
            locationError = 'Location permission denied';
          });
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      setState(() {
        isLoadingLocation = false;
      });

      // Validate radius after getting location
      _validateRadius();
    } on PlatformException catch (e) {
      setState(() {
        isLoadingLocation = false;
        locationError = e.message ?? 'Failed to get location';
      });
      if (e.code == 'IO_ERROR') {
        debugPrint(
            'A network error occurred trying to lookup the supplied coordinates: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
        locationError = 'An unknown error occurred';
      });
      debugPrint('An unknown error occurred: $e');
    }
  }

  void _validateRadius() {
    final companyState = context.read<GetCompanyBloc>().state;
    companyState.maybeWhen(
      success: (company) {
        if (latitude != null && longitude != null) {
          final companyLat = double.tryParse(company.latitude ?? '0') ?? 0.0;
          final companyLong = double.tryParse(company.longitude ?? '0') ?? 0.0;
          final radiusKm = double.tryParse(company.radiusKm ?? '0') ?? 0.0;

          distance = RadiusCalculate.calculateDistance(
            latitude!,
            longitude!,
            companyLat,
            companyLong,
          );

          setState(() {
            isWithinRadius = true;
          });

          debugPrint(
              'Distance: $distance km, Radius: $radiusKm km, Within: $isWithinRadius');
        }
      },
      orElse: () {
        setState(() {
          isWithinRadius = true;
        });
      },
    );
  }

  String _getAttendanceTypeName() {
    switch (widget.attendanceType.toLowerCase()) {
      case 'face':
      case 'face_recognition_only':
        return 'Face Recognition';
      case 'qr':
      case 'qr_code_only':
        return 'QR Code';
      case 'location_based_only':
        return 'Location Based';
      case 'hybrid':
        return 'Hybrid';
      default:
        return 'Manual';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetCompanyBloc, GetCompanyState>(
      listener: (context, state) {
        // When company data is loaded, validate radius
        state.maybeWhen(
          success: (_) {
            if (latitude != null && longitude != null) {
              _validateRadius();
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SpaceHeight(20),
                          _buildResultCard(),
                          const SpaceHeight(24),
                          _buildLocationInfo(),
                          const SpaceHeight(24),
                          _buildActionButtons(),
                          const SpaceHeight(40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Column(
      children: [
        // biru atas
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 240,
            decoration: const BoxDecoration(color: Color(0xFF1E5EFF)),
            child: Stack(
              children: [
                Positioned(
                  left: -150,
                  top: -380,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.topRight, // cahaya dari kanan atas
                          radius: 1.2,
                          colors: [
                            Colors.white.withValues(alpha: 0.18), // terang
                            Colors.white.withValues(alpha: 0.0), // gelap
                          ],
                          stops: [0.2, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -100,
                  top: 50,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.topLeft, // cahaya dari kanan atas
                          radius: 1,
                          colors: [
                            Colors.white.withValues(alpha: 0.1), // terang
                            Colors.white.withValues(alpha: -1), // gelap
                          ],
                          stops: [0.1, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // putih bawah
        Expanded(
          child: Container(
            color: const Color(0xFFF5F7FB),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SpaceWidth(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCheckin ? 'Check In' : 'Check Out',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getAttendanceTypeName(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return BlocBuilder<GetCompanyBloc, GetCompanyState>(
      builder: (context, state) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isWithinRadius
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isWithinRadius
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200)
                              .withValues(alpha: 0.4),
                          blurRadius: 1,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      isWithinRadius
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SpaceHeight(24),

                  // Title
                  Text(
                    isWithinRadius
                        ? 'Lokasi Terverifikasi!'
                        : 'Lokasi Tidak Valid',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1e3c72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SpaceHeight(8),

                  // Subtitle
                  Text(
                    isWithinRadius
                        ? 'Anda berada di area yang valid'
                        : 'Anda berada di luar area yang ditentukan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SpaceHeight(20),

                  // Distance info
                  if (distance > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.straighten_rounded,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SpaceWidth(8),
                          Text(
                            'Jarak: ${distance.toStringAsFixed(2)} km',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SpaceWidth(4),
                          state.maybeWhen(
                            success: (company) {
                              final radiusKm =
                                  double.tryParse(company.radiusKm ?? '0') ??
                                      0.0;
                              return Text(
                                '/ ${radiusKm.toStringAsFixed(2)} km',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade600,
                                ),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isWithinRadius
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isWithinRadius
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isWithinRadius
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          color: isWithinRadius
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          size: 24,
                        ),
                        const SpaceWidth(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWithinRadius
                                    ? 'Lokasi Anda sesuai dengan area kantor'
                                    : 'Pastikan Anda berada di area kantor',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isWithinRadius
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                ),
                              ),
                              Text(
                                isWithinRadius
                                    ? ''
                                    : 'Silahkan masuk ke area yang ditentukan',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo() {
    if (isLoadingLocation) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1e3c72)),
              ),
            ),
            const SpaceWidth(12),
            Text(
              'Mendapatkan lokasi...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    if (locationError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_off_rounded,
              color: Colors.red.shade400,
              size: 40,
            ),
            const SpaceHeight(12),
            Text(
              'Gagal mendapatkan lokasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SpaceHeight(8),
            Text(
              locationError!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: getCurrentPosition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e3c72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Coba Lagi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e3c72).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF1e3c72),
                  size: 20,
                ),
              ),
              const SpaceWidth(12),
              Text(
                'Koordinat Lokasi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1e3c72),
                ),
              ),
            ],
          ),
          Divider(),
          _buildLocationRow(
            icon: Icons.location_on_rounded,
            label: 'Latitude',
            value: latitude?.toStringAsFixed(6) ?? '-',
          ),
          Divider(),
          _buildLocationRow(
            icon: Icons.location_on_rounded,
            label: 'Longitude',
            value: longitude?.toStringAsFixed(6) ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SpaceWidth(8),
          SizedBox(
            width: 100,
            child: Text(
              '$label ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          VerticalDivider(
            thickness: 2,
            width: 40,
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1e3c72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Main action button (Checkin or Checkout)
          // Only show if within radius, location is available, and no error
          if (isWithinRadius && !isLoadingLocation && locationError == null)
            widget.isCheckin ? _buildCheckinButton() : _buildCheckoutButton(),

          // Warning message if outside radius
          // if (!isWithinRadius && !isLoadingLocation && locationError == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                const SpaceWidth(12),
                Expanded(
                  child: Text(
                    'Anda berada di luar radius yang ditentukan. Check-in/Check-out tidak dapat dilanjutkan.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Retry button for location-based
          if (widget.attendanceType.toLowerCase() == 'location_based_only' &&
              !isLoadingLocation)
            const SpaceHeight(16),
          if (widget.attendanceType.toLowerCase() == 'location_based_only' &&
              !isLoadingLocation)
            _buildRetryLocationButton(),

          // Alternative methods for other attendance types
          if (widget.attendanceType.toLowerCase() == 'face' ||
              widget.attendanceType.toLowerCase() == 'face_recognition_only')
            const SpaceHeight(16),
          if (widget.attendanceType.toLowerCase() == 'face' ||
              widget.attendanceType.toLowerCase() == 'face_recognition_only')
            _buildRetryFaceButton(),

          if (widget.attendanceType.toLowerCase() == 'qr' ||
              widget.attendanceType.toLowerCase() == 'qr_code_only')
            const SpaceHeight(16),
          if (widget.attendanceType.toLowerCase() == 'qr' ||
              widget.attendanceType.toLowerCase() == 'qr_code_only')
            _buildRetryQRButton(),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog({
    required bool isCheckin,
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCheckin
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCheckin ? Icons.login_rounded : Icons.logout_rounded,
                  color: isCheckin ? Colors.green : Colors.blue,
                  size: 24,
                ),
              ),
              const SpaceWidth(12),
              Expanded(
                child: Text(
                  'Konfirmasi ${isCheckin ? "Check-In" : "Check-Out"}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin melanjutkan ${isCheckin ? "check-in" : "check-out"}?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SpaceHeight(16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildConfirmationInfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Lokasi',
                      value: 'Terverifikasi',
                      color: Colors.green,
                    ),
                    const SpaceHeight(8),
                    _buildConfirmationInfoRow(
                      icon: Icons.straighten_rounded,
                      label: 'Jarak',
                      value: '${distance.toStringAsFixed(2)} km',
                      color: Colors.blue,
                    ),
                    const SpaceHeight(8),
                    _buildConfirmationInfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'Waktu',
                      value: DateFormat('dd MMM yyyy, HH:mm:ss')
                          .format(DateTime.now()),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckin ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Ya, Lanjutkan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirm();
    }
  }

  Widget _buildConfirmationInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SpaceWidth(8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckinButton() {
    return BlocConsumer<CheckinAttendanceBloc, CheckinAttendanceState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          loaded: (responseModel) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceSuccessPage(
                  status: 'Datang',
                ),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    _showConfirmationDialog(
                      isCheckin: true,
                      onConfirm: () {
                        context.read<CheckinAttendanceBloc>().add(
                              CheckinAttendanceEvent.checkin(
                                latitude?.toString() ?? '0',
                                longitude?.toString() ?? '0',
                              ),
                            );
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade500, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SpaceWidth(8),
                          Text(
                            'Lanjutkan Check-In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutButton() {
    return BlocConsumer<CheckoutAttendanceBloc, CheckoutAttendanceState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          loaded: (responseModel) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceSuccessPage(
                  status: 'Pulang',
                ),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    _showConfirmationDialog(
                      isCheckin: false,
                      onConfirm: () {
                        context.read<CheckoutAttendanceBloc>().add(
                              CheckoutAttendanceEvent.checkout(
                                latitude?.toString() ?? '0',
                                longitude?.toString() ?? '0',
                              ),
                            );
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SpaceWidth(8),
                          Text(
                            'Lanjutkan Check-Out',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetryLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: getCurrentPosition,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1e3c72),
          side: const BorderSide(color: Color(0xFF1e3c72), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: Text(
          'Perbarui Lokasi',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRetryFaceButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FaceDetectorCheckinPage(
                isCheckedIn: widget.isCheckin,
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1e3c72),
          side: const BorderSide(color: Color(0xFF1e3c72), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.face_rounded, size: 20),
        label: Text(
          'Ambil Wajah Lagi',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRetryQRButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.pushReplacement(ScannerPage(isCheckin: widget.isCheckin));
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1e3c72),
          side: const BorderSide(color: Color(0xFF1e3c72), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
        label: Text(
          'Scan QR Code Lagi',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width * 0.20,
      size.height,
      size.width * 0.45,
      size.height - 20,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 50,
      size.width,
      size.height - 10,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
