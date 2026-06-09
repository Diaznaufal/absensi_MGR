import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attandences/face_detector_checkin_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attandences/attendance_result_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attandences/scanner_page.dart';
import 'package:flutter_absensi_app/presentation/leaves/pages/leave_page.dart';
import 'package:flutter_absensi_app/presentation/overtimes/pages/overtime_page.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../../profile/bloc/get_user/get_user_bloc.dart';
import 'register_face_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String? faceEmbedding;
  double? latitude;
  double? longitude;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _initializeFaceEmbedding();

    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());

    getCurrentPosition();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _slideController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        _cardController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;
      setState(() {});
    } on PlatformException catch (e) {
      if (e.code == 'IO_ERROR') {
        debugPrint('Network error occurred: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unknown error occurred: $e');
    }
  }

  Future<void> _initializeFaceEmbedding() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      setState(() {
        faceEmbedding = authData?.user?.faceEmbedding;
      });
    } catch (e) {
      debugPrint('Error fetching auth data: $e');
      setState(() {
        faceEmbedding = null;
      });
    }
  }

  Future<void> _onRefresh() async {
    // Refresh all data
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());

    // Refresh face embedding
    await _initializeFaceEmbedding();

    // Wait a bit for the blocs to process
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallDevice = size.height < 700;
    final double headerBottomPadding = isSmallDevice ? 60 : 75;
    final double cardOverlap = isSmallDevice ? 62 : 70;

    return Scaffold(
      backgroundColor: const Color(0xBAE7E8EC),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Color(0xFF0A49B7),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildHeader(headerBottomPadding),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: -cardOverlap,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _cardAnimation,
                            child: _buildTimeCard(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: cardOverlap + 14,
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildMenuGrid(),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildHeader(double bottomPadding) {
    return FutureBuilder(
      future: AuthLocalDatasource().getAuthData(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return _buildLoadingHeader(bottomPadding);
        // }

        // if (!snapshot.hasData || snapshot.data == null) {
        //   return _buildFallbackHeader(bottomPadding);
        // }

        return ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              bottomPadding,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0948B2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xA1B8BBBE),
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: Center(
                              child: Text(
                                'U',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ))),
                    const SpaceWidth(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang 👋',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            'Karyawan',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Manager',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SpaceHeight(14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeaderChip(Icons.badge_rounded, 'Employe'),
                    _buildHeaderChip(Icons.business_rounded, 'Manager'),
                    _buildHeaderChip(Icons.schedule_rounded, 'Siang'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackHeader(double bottomPadding) {
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
        decoration: const BoxDecoration(
          color: Color(0xFF0A49B7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xA1B8BBBE),
                borderRadius: BorderRadius.circular(27),
              ),
              child: Center(
                child: Text(
                  'U',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SpaceWidth(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Karyawan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildLoadingHeader(double bottomPadding) {
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
        decoration: const BoxDecoration(
          color: Color(0xFF1E5EFF),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(27),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            const SpaceWidth(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SpaceHeight(6),
                  Container(
                    height: 24,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SpaceHeight(8),
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
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

  Widget _buildTimeCard() {
    return FutureBuilder(
      future: AuthLocalDatasource().getAuthData(),
      builder: (context, snapshot) {
        String startTime = '08:00';
        String endTime = '17:00';

        // if (snapshot.hasData && snapshot.data != null) {
        //   final authData = snapshot.data!;
        //   startTime = authData.user?.shiftKerja?.startTime ??
        //       authData.defaultShiftDetail?.startTime?.toFormattedTime() ??
        //       '08:00';
        //   endTime = authData.user?.shiftKerja?.endTime ??
        //       authData.defaultShiftDetail?.endTime?.toFormattedTime() ??
        //       '17:00';
        // }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E9F4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2D78).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu sekarang',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A94B4),
                      ),
                    ),
                    const SpaceHeight(4),
                    Text(
                      "${(DateTime.now().toFormattedTime())} WIB",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 38,
                        color: const Color(0xFF1B2D78),
                        height: 0.95,
                      ),
                    ),
                    const SpaceHeight(8),
                    Text(
                      '${DateTime.now().toFormattedDate()}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF8A94B4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                color: const Color(0xFFE2E6F3),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam kerja',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A94B4),
                      ),
                    ),
                    const SpaceHeight(6),
                    Text(
                      '$startTime-$endTime',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF1B2D78),
                      ),
                    ),
                    const SpaceHeight(6),
                    Text(
                      'Shift $startTime',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF8A94B4),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B2D78),
          ),
        ),
        const SpaceHeight(12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildAttendanceButton(isCheckIn: true),
            _buildAttendanceButton(isCheckIn: false),
          ],
        ),
        const SpaceHeight(18),
        Text(
          'Layanan Karyawan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B2D78),
          ),
        ),
        const SpaceHeight(12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _buildModernButtonCuti(
              icon: Icons.event_busy_rounded,
              label: 'Izin / Cuti',
              subtitle: 'Ajukan izin atau cuti kamu',
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE5EA), Color(0xFFFFE5EA)],
              ),
              onPressed: () async {
                // await _checkBackendAndNavigate(() {
                context.push(const LeavePage());
                // });
              },
            ),
            _buildModernButtonLembur(
              icon: Icons.more_time_rounded,
              label: 'Lembur',
              subtitle: 'Ajukan lembur kerja kamu',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFDCE7FF),
                  Color(0xFFDCE7FF),
                ],
              ),
              onPressed: () async {
                // await _checkBackendAndNavigate(() {
                context.push(const OvertimePage());
                // });
              },
            ),
            _buildModernButtonPengaduan(
              icon: Icons.campaign,
              label: 'Pengaduan ',
              subtitle: 'Sampaikan pengaduan ke perusahaan',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFEDB8),
                  Color(0xFFFFEDB8),
                ],
              ),
              onPressed: () async {
                // await _checkBackendAndNavigate(() {
                context.push(PengaduanPage());
                // });
              },
            ),
            _buildModernButtonLibur(
              icon: Icons.calendar_month,
              label: 'Libur Karyawan',
              subtitle: 'Ajukan dan \nkelola jadwal libur kamu',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8D8FF),
                  Color(0xFFE8D8FF),
                ],
              ),
              onPressed: () async {
                // await _checkBackendAndNavigate(() {
                context.push(const OvertimePage());
                // });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceButton({required bool isCheckIn}) {
    return BlocBuilder<GetCompanyBloc, GetCompanyState>(
      builder: (context, state) {
        final latitudePoint = state.maybeWhen(
          orElse: () => 0.0,
          success: (data) => double.parse(data.latitude!),
        );
        final longitudePoint = state.maybeWhen(
          orElse: () => 0.0,
          success: (data) => double.parse(data.longitude!),
        );
        final radiusPoint = state.maybeWhen(
          orElse: () => 0.0,
          success: (data) => double.parse(data.radiusKm!),
        );
        final attendanceType = state.maybeWhen(
          orElse: () => 'Location',
          success: (data) => data.attendanceType!,
        );

        return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
          builder: (context, state) {
            final isCheckedin = state.maybeWhen(
              orElse: () => false,
              success: (data) => data.isCheckedin,
            );
            final isCheckout = state.maybeWhen(
              orElse: () => false,
              success: (data) => data.isCheckedout,
            );

            return _buildModernAttendanceButton(
              isCheckIn: isCheckIn,
              isCheckedin: isCheckedin,
              isCheckout: isCheckout,
              onPressed: () => _handleAttendance(
                isCheckIn: isCheckIn,
                isCheckedin: isCheckedin,
                isCheckout: isCheckout,
                latitudePoint: latitudePoint,
                longitudePoint: longitudePoint,
                radiusPoint: radiusPoint,
                attendanceType: attendanceType,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaceAttendanceButton() {
    return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
      builder: (context, state) {
        final isCheckout = state.maybeWhen(
          orElse: () => false,
          success: (data) => data.isCheckedout,
        );
        final isCheckIn = state.maybeWhen(
          orElse: () => false,
          success: (data) => data.isCheckedin,
        );

        return BlocBuilder<GetCompanyBloc, GetCompanyState>(
          builder: (context, state) {
            final latitudePoint = state.maybeWhen(
              orElse: () => 0.0,
              success: (data) => double.parse(data.latitude!),
            );
            final longitudePoint = state.maybeWhen(
              orElse: () => 0.0,
              success: (data) => double.parse(data.longitude!),
            );
            final radiusPoint = state.maybeWhen(
              orElse: () => 0.0,
              success: (data) => double.parse(data.radiusKm!),
            );

            String buttonText = 'Face Attendance Today';
            if (!isCheckIn) {
              buttonText = 'Check In with Face';
            } else if (!isCheckout) {
              buttonText = 'Check Out with Face';
            } else {
              buttonText = 'Attendance Complete';
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1e3c72),
                    Color(0xFF3b82c9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1e3c72).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _handleFaceAttendance(
                    isCheckIn: isCheckIn,
                    isCheckout: isCheckout,
                    latitudePoint: latitudePoint,
                    longitudePoint: longitudePoint,
                    radiusPoint: radiusPoint,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.attendance.svg(
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: 24,
                          height: 24,
                        ),
                        const SpaceWidth(12),
                        Text(
                          buttonText,
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
      },
    );
  }

  Future<void> _handleAttendance({
    required bool isCheckIn,
    required bool isCheckedin,
    required bool isCheckout,
    required double latitudePoint,
    required double longitudePoint,
    required double radiusPoint,
    required String attendanceType,
  }) async {
    try {
      // Check face embedding FIRST for Face attendance type
      if (attendanceType == 'face_recognition_only' ||
          attendanceType == 'hybrid') {
        if (faceEmbedding == null || faceEmbedding!.isEmpty) {
          _showRegisterFaceDialog();
          return;
        }
      }

      // THEN check location and other validations
      final distanceKm = RadiusCalculate.calculateDistance(
        latitude ?? 0.0,
        longitude ?? 0.0,
        latitudePoint,
        longitudePoint,
      );

      // final position = await Geolocator.getCurrentPosition();

      // // if (position.isMocked) {
      // //   _showFakeGpsDialog();
      // //   return;
      // // }

      // if (distanceKm > radiusPoint &&
      //     (attendanceType == 'location_based_only' ||
      //         attendanceType == 'hybrid')) {
      //   _showOutOfAreaDialog(
      //     distance: distanceKm,
      //     allowedRadius: radiusPoint,
      //   );
      //   return;
      // }

      if (isCheckIn) {
        if (isCheckedin) {
          _showModernDialog(
            'Already Checked In',
            'You have already checked in today.',
            Icons.check_circle_rounded,
            Colors.green,
          );
          return;
        }
      } else {
        // if (!isCheckedin) {
        //   _showModernDialog(
        //     'Check In Required',
        //     'Please check in first before checking out.',
        //     Icons.info_rounded,
        //     Colors.blue,
        //   );
        //   return;
        // }
        // if (isCheckout) {
        //   _showModernDialog(
        //     'Already Checked Out',
        //     'You have already checked out today.',
        //     Icons.check_circle_rounded,
        //     Colors.green,
        //   );
        //   return;
        // }
      }

      _navigateToAttendance(attendanceType, isCheckIn);
    } catch (e) {
      _showModernDialog(
        'Error',
        'An error occurred: $e',
        Icons.error_rounded,
        Colors.red,
      );
    }
  }

  Future<void> _handleFaceAttendance({
    required bool isCheckIn,
    required bool isCheckout,
    required double latitudePoint,
    required double longitudePoint,
    required double radiusPoint,
  }) async {
    try {
      final distanceKm = RadiusCalculate.calculateDistance(
        latitude ?? 0.0,
        longitude ?? 0.0,
        latitudePoint,
        longitudePoint,
      );

      // final position = await Geolocator.getCurrentPosition();

      // if (position.isMocked) {
      //   _showModernSnackBar(
      //     'You are using fake location',
      //     Icons.error_outline,
      //     Colors.red,
      //   );
      //   return;
      // }

      // if (distanceKm > radiusPoint) {
      //   _showModernSnackBar(
      //     'You are outside the attendance area',
      //     Icons.location_off,
      //     Colors.orange,
      //   );
      //   return;
      // }

      if (!isCheckIn) {
        // await _checkBackendAndNavigate(() {
        context.push(FaceDetectorCheckinPage(
          isCheckedIn: true,
          latitude: latitude,
          longitude: longitude,
        ));
        // });
      } else if (!isCheckout) {
        // await _checkBackendAndNavigate(() {
        context.push(FaceDetectorCheckinPage(
          isCheckedIn: false,
          latitude: latitude,
          longitude: longitude,
        ));
        // });
      } else {
        _showModernSnackBar(
          'You have completed attendance today',
          Icons.check_circle,
          Colors.green,
        );
      }
    } catch (e) {
      _showModernSnackBar(
        'Error: $e',
        Icons.error,
        Colors.red,
      );
    }
  }

  void _showModernDialog(
      String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SpaceHeight(16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(8),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(24),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SpaceWidth(8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _checkBackendAndNavigate(Function navigate) async {
    // Show loading indicator
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    // Check backend connection
    final isConnected = await BackendConnectionHelper.checkBackendSocket();

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (!mounted) return;

    if (isConnected) {
      // Backend is reachable, proceed with navigation
      navigate();
    } else {
      // Backend is not reachable, show error dialog
      BackendConnectionDialog.show(
        context,
        customMessage: 'Tidak dapat terhubung ke backend saat ini',
      );
    }
  }

  // Future<void> _navigateToAttendance(
  //     String attendanceType, bool isCheckIn) async {
  //   // await _checkBackendAndNavigate(() {
  //   if (attendanceType == 'face_recognition_only' ||
  //       attendanceType == 'hybrid') {
  //     context.push(FaceDetectorCheckinPage(
  //       isCheckedIn: isCheckIn,
  //       latitude: latitude,
  //       longitude: longitude,
  //     ));
  //   } else {
  //     // For location_based_only and other types, pass lat/long
  //     context.push(AttendanceResultPage(
  //       isCheckin: isCheckIn,
  //       isMatch: true,
  //       attendanceType: attendanceType,
  //       latitude: latitude,
  //       longitude: longitude,
  //     ));
  //   }
  //   // });
  // }
  Future<void> _navigateToAttendance(
    String attendanceType,
    bool isCheckIn,
  ) async {
    context.push(
      FaceDetectorCheckinPage(
        isCheckedIn: isCheckIn,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  void _showRegisterFaceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e3c72).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.face_rounded,
                  color: Color(0xFF1e3c72),
                  size: 32,
                ),
              ),
              const SpaceHeight(16),
              Text(
                'Register Face Required',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(8),
              Text(
                'You need to register your face first before using face attendance. Would you like to register now?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child: Text(
                              'Later',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SpaceWidth(12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1e3c72), Color(0xFF3b82c9)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context);
                            context.push(const RegisterFacePage());
                          },
                          child: Center(
                            child: Text(
                              'Register Now',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFakeGpsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.1),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.gps_off_rounded,
                  color: Colors.red[700],
                  size: 48,
                ),
              ),
              const SpaceHeight(24),
              Text(
                'Fake GPS Terdeteksi!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(12),
              Text(
                'Sistem mendeteksi bahwa HP Anda menggunakan aplikasi fake GPS atau mock location.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SpaceWidth(12),
                    Expanded(
                      child: Text(
                        'Harap nonaktifkan fake GPS terlebih dahulu untuk melanjutkan absensi.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceHeight(28),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red[600]!,
                      Colors.red[700]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Mengerti',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOutOfAreaDialog({
    required double distance,
    required double allowedRadius,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.orange.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  color: Colors.orange[700],
                  size: 48,
                ),
              ),
              const SpaceHeight(24),
              Text(
                'Lokasi Di Luar Area!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(12),
              Text(
                'Anda berada di luar jangkauan area absensi yang telah ditentukan oleh kantor.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(16),
              // Distance information box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SpaceWidth(8),
                        Text(
                          'Informasi Jarak',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jarak Anda:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${distance.toStringAsFixed(2)} km',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight(6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Radius Maksimal:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${allowedRadius.toStringAsFixed(2)} km',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight(6),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.red.withOpacity(0.2),
                    ),
                    const SpaceHeight(6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kelebihan Jarak:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${(distance - allowedRadius).toStringAsFixed(2)} km',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SpaceHeight(12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SpaceWidth(12),
                    Expanded(
                      child: Text(
                        'Harap mendekat ke lokasi kantor untuk dapat melakukan absensi.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceHeight(28),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange[600]!,
                      Colors.orange[700]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Mengerti',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernButtonCuti({
    required IconData icon,
    required String label,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1B2D78).withOpacity(0.08),
                blurRadius: 5,
                spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: 32,
              ),
            ),
            const SpaceHeight(12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernButtonLembur({
    required IconData icon,
    required String label,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1B2D78).withOpacity(0.08),
                blurRadius: 5,
                spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0059FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: 32,
              ),
            ),
            const SpaceHeight(12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0059FF),
              ),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF0059FF).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    size: 18,
                    color: Color(0xFF0059FF),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernButtonPengaduan({
    required IconData icon,
    required String label,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1B2D78).withOpacity(0.08),
                blurRadius: 5,
                spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: 32,
              ),
            ),
            const SpaceHeight(12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    size: 18,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernButtonLibur({
    required IconData icon,
    required String label,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1B2D78).withOpacity(0.08),
                blurRadius: 5,
                spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: 32,
              ),
            ),
            const SpaceHeight(12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    size: 18,
                    color: Colors.purple,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernAttendanceButton({
    required bool isCheckIn,
    required bool isCheckedin,
    required bool isCheckout,
    required VoidCallback onPressed,
  }) {
    final bool isDisabled = false;

    final String label = isCheckIn ? 'Check In' : 'Check Out';
    final IconData icon =
        isCheckIn ? Icons.login_rounded : Icons.logout_rounded;

    final LinearGradient gradient = isCheckIn
        ? const LinearGradient(colors: [Color(0xFFDFF5E7), Color(0xFFD2F0DE)])
        : const LinearGradient(colors: [Color(0xFFFDEADF), Color(0xFFF9E3D5)]);

    final LinearGradient disabledGradient =
        const LinearGradient(colors: [Color(0xFFF0F2F7), Color(0xFFE9ECF4)]);

    final Color iconColor =
        isCheckIn ? const Color(0xFFffffff) : const Color(0xFFffffff);
    final Color textColor =
        isCheckIn ? const Color(0xFF1F8B4D) : const Color(0xFFFE600B);
    final Color containerColor =
        isCheckIn ? const Color(0xFF1F8B4D) : const Color(0xFFFE600B);
    final Color disabledColor = const Color(0xFFA1A9C3);
    final Color disabledColoricon = const Color(0xFFffffff);

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDisabled ? disabledGradient : gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2D78).withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDisabled ? disabledColor : containerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isDisabled ? disabledColoricon : iconColor,
                size: 24,
              ),
            ),
            const SpaceHeight(8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDisabled ? disabledColor : textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SpaceHeight(2),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.95)),
          const SpaceWidth(4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
