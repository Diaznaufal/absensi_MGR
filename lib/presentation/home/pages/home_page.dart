import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/user_response_model.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/get_all_leaves/get_all_leaves_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attandences/face_detector_checkin_page.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/pages/leave_page.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/page/liburKaryawan_page.dart';
import 'package:flutter_absensi_app/presentation/notifikasi/page/notifikasi_page.dart';
import 'package:flutter_absensi_app/presentation/overtimes/pages/overtime_page.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/page/pengaduan_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
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
  final AttendanceRemoteDatasource _attendanceDatasource =
      AttendanceRemoteDatasource();
  String? faceEmbedding;
  double? latitude;
  double? longitude;
  bool _isCheckingLocation = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;
  UserResponseModel? _lastUser;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _initializeFaceEmbedding();

    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());

    context.read<GetAllLeavesBloc>().add(GetAllLeavesEvent.getAllLeaves());

    getCurrentPositionOneTime(); // Memanggil fungsi satu kali di awal dengan jeda aman
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
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  // Fungsi pengambilan lokasi 1 kali di awal saat masuk Home secara aman
  Future<void> getCurrentPositionOneTime() async {
    if (_isCheckingLocation) return;
    try {
      setState(() {
        _isCheckingLocation = true;
      });

      LocationPermission permission;
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission(); // Memicu Popup 1
        if (permission == LocationPermission.denied) {
          setState(() => _isCheckingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isCheckingLocation = false);
        return;
      }

      // Memberikan jeda waktu 1.5 detik agar Popup 1 benar-benar tertutup sempurna di sistem OS
      await Future.delayed(const Duration(milliseconds: 1500));

      // Baru ambil posisi koordinat di sini (Memicu Popup 2 jika GPS user mati)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        _isCheckingLocation = false;
      });
    } catch (e) {
      debugPrint('Error mengambil lokasi di awal: $e');
      setState(() => _isCheckingLocation = false);
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
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());

    context.read<GetAllLeavesBloc>().add(GetAllLeavesEvent.getAllLeaves());

    await _initializeFaceEmbedding();
    await getCurrentPositionOneTime(); // Mengambil ulang koordinat saat halaman di-refresh
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallDevice = size.height < 700;
    final double headerBottomPadding = isSmallDevice ? 65 : 70;
    final double cardOverlap = isSmallDevice ? 120 : 130;

    return Scaffold(
      backgroundColor: const Color(0xBAE7E8EC),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF0A49B7),
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
                      BlocBuilder<GetUserBloc, GetUserState>(
                        builder: (context, userState) {
                          return userState.maybeWhen(
                            success: (user) {
                              _lastUser = user;

                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildHeader(
                                  headerBottomPadding,
                                  user,
                                ),
                              );
                            },
                            orElse: () {
                              if (_lastUser != null) {
                                return _buildHeader(
                                  headerBottomPadding,
                                  _lastUser!,
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        top: cardOverlap,
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
                  SizedBox(height: cardOverlap - 10),
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

  Widget _buildHeader(double bottomPadding, UserResponseModel user) {
    final employee = user.employee;
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
        decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
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
                      child: user.avatar != null && user.avatar!.isNotEmpty
                          ? Image.network(
                              user.avatar!,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    user.name != null && user.name!.isNotEmpty
                                        ? user.name!.trim()[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                user.name != null && user.name!.isNotEmpty
                                    ? user.name!.trim()[0].toUpperCase()
                                    : 'U',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
                        user.name != null && user.name!.isNotEmpty
                            ? user.name!.split(' ').take(2).join(' ')
                            : '',
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
                        employee?.nameProduct ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.push(const NotifikasiPage());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Badge(
                      offset: Offset(10, -10),
                      backgroundColor: Colors.red,
                      label: Text("3"),
                      textColor: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SpaceHeight(14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildHeaderChip(Icons.badge_rounded, user.roleLabel ?? ''),
                _buildHeaderChip(
                    Icons.apartment_rounded, employee?.nameDivision ?? ''),
                _buildHeaderChip(
                    Icons.business_rounded, employee?.namePosition ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
      builder: (context, checkedInState) {
        final Map<String, dynamic> absenceTodayData = checkedInState.maybeWhen(
          success: (absenceData) =>
              absenceData is Map<String, dynamic> ? absenceData : {},
          orElse: () => {},
        );

        final bool alreadyCheckedIn =
            absenceTodayData['already_checked_in'] == true;

        final String? jamMasukRaw = absenceTodayData['jam_masuk']?.toString();

        final String statusLabel =
            absenceTodayData['status_label']?.toString() ?? '';

        final String currentStatus =
            absenceTodayData['status']?.toString() ?? '';

        final bool isDayOff = statusLabel == 'Day Off' || currentStatus == '2';

        final bool isCuti = statusLabel == 'Cuti' || currentStatus == '4';

        final String checkInJam =
            (jamMasukRaw != null && jamMasukRaw.length >= 5)
                ? jamMasukRaw.substring(0, 5)
                : '-';

        // ============================================
        // AMBIL LANGSUNG DARI /absence/today
        // ============================================
        final Map<String, dynamic> workshift =
            absenceTodayData['workshift'] is Map
                ? Map<String, dynamic>.from(
                    absenceTodayData['workshift'] as Map,
                  )
                : {};

        final String shiftName =
            workshift['name_workshift']?.toString() ?? 'Memuat...';

        final String rawClockIn = workshift['clock_in']?.toString() ?? '';

        final String rawClockOut = workshift['clock_out']?.toString() ?? '';

        final String jadwalClockIn =
            rawClockIn.length >= 5 ? rawClockIn.substring(0, 5) : '00:00';

        final String jadwalClockOut =
            rawClockOut.length >= 5 ? rawClockOut.substring(0, 5) : '00:00';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          DateTime.now().toFormattedTime(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 36,
                            color: const Color(0xFF1B2D78),
                            height: 0.95,
                          ),
                        ),
                        const SpaceHeight(4),
                        Text(
                          DateTime.now().toFormattedDate(),
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
                    width: 110,
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
                          '$jadwalClockIn-$jadwalClockOut',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF1B2D78),
                          ),
                        ),
                        const SpaceHeight(6),
                        Text(
                          shiftName,
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
              const Divider(thickness: 1.5),
              if (alreadyCheckedIn)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Anda sudah melakukan Check In hari ini pukul : $checkInJam\n',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.redAccent,
                        ),
                      ),
                      TextSpan(
                        text: 'Jangan lupa untuk melakukan Check Out',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isDayOff)
                Text(
                  'Hari ini jadwal Day Off anda. Selamat beristirahat!',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.redAccent,
                  ),
                )
              else if (isCuti)
                Text(
                  'Hari ini anda sedang mengambil masa Cuti',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.redAccent,
                  ),
                )
              else
                Text(
                  'Belum ada riwayat Absen hari ini. Silahkan melakukan Check In',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.redAccent,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildModernButtonCuti(
                    icon: Icons.event_busy_rounded,
                    label: 'Izin / Cuti',
                    subtitle: 'Ajukan izin atau cuti anda',
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFE5EA), Color(0xFFFFE5EA)]),
                    onPressed: () => context.push(const LeavePage()),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildModernButtonLembur(
                    icon: Icons.more_time_rounded,
                    label: 'Lembur',
                    subtitle: 'Ajukan lembur kerja anda',
                    gradient: const LinearGradient(
                        colors: [Color(0xFFDCE7FF), Color(0xFFDCE7FF)]),
                    onPressed: () => context.push(const OvertimePage()),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildModernButtonPengaduan(
                    icon: Icons.campaign,
                    label: 'Pengaduan ',
                    subtitle: 'Sampaikan pengaduan ke perusahaan',
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFEDB8), Color(0xFFFFEDB8)]),
                    onPressed: () => context.push(PengaduanPage()),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildModernButtonLibur(
                    icon: Icons.calendar_month,
                    label: 'Libur Karyawan',
                    subtitle: 'Ajukan dan \nkelola jadwal libur anda',
                    gradient: const LinearGradient(
                        colors: [Color(0xFFE8D8FF), Color(0xFFE8D8FF)]),
                    onPressed: () => context.push(LiburkaryawanPage()),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceButton({required bool isCheckIn}) {
    return BlocBuilder<GetCompanyBloc, GetCompanyState>(
      builder: (context, companyState) {
        final latitudePoint = companyState.maybeWhen(
            orElse: () => 0.0, success: (data) => double.parse(data.latitude!));
        final longitudePoint = companyState.maybeWhen(
            orElse: () => 0.0,
            success: (data) => double.parse(data.longitude!));
        final radiusPoint = companyState.maybeWhen(
            orElse: () => 0.0, success: (data) => double.parse(data.radiusKm!));
        final attendanceType = companyState.maybeWhen(
            orElse: () => 'Location', success: (data) => data.attendanceType!);

        return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
          builder: (context, checkedInState) {
            final Map<String, dynamic> absenceTodayData =
                checkedInState.maybeWhen(
              success: (absenceData) => absenceData,
              orElse: () => {},
            );

            final bool hasSchedule = absenceTodayData['has_schedule'] == true;
            final bool alreadyCheckedIn =
                absenceTodayData['already_checked_in'] == true;
            final String idScheduleApi =
                absenceTodayData['id_schedule']?.toString() ?? '';
            final String statusLabel =
                absenceTodayData['status_label']?.toString() ?? '';
            final String currentStatus =
                absenceTodayData['status']?.toString() ?? '';

            final bool isDayOff =
                statusLabel == 'Day Off' || currentStatus == '2';
            final bool isCuti = statusLabel == 'Cuti' || currentStatus == '4';

            bool isDisabled = true;

            if (isCheckIn) {
              isDisabled =
                  !(hasSchedule && !alreadyCheckedIn && !isDayOff && !isCuti);
            } else {
              isDisabled = !(hasSchedule && alreadyCheckedIn);
            }

            return _buildModernAttendanceButton(
              isCheckIn: isCheckIn,
              isDisabledButton: isDisabled,
              onPressed: () => _handleAttendance(
                isCheckIn: isCheckIn,
                idSchedule: idScheduleApi,
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

  Future<void> _handleAttendance({
    required bool isCheckIn,
    required String idSchedule,
    required double latitudePoint,
    required double longitudePoint,
    required double radiusPoint,
    required String attendanceType,
  }) async {
    try {
      final faceStatusResult =
          await AttendanceRemoteDatasource().checkFaceRegistrationStatus();
      final isRegistered =
          faceStatusResult.fold((error) => false, (value) => value);

      if (!isRegistered) {
        _showRegisterFaceDialog();
        return;
      }

      // TIDAK ADA fungsi mengambil lokasi (getCurrentPosition) di sini lagi.
      // Tombol langsung mencocokkan variabel latitude/longitude yang sudah didapat sejak awal masuk aplikasi.

      if (latitude == null || longitude == null) {
        _showModernDialog(
            'Lokasi Belum Siap',
            'Gagal mendeteksi lokasi dasar perangkat. Coba muat ulang halaman ini.',
            Icons.location_off_rounded,
            Colors.orange);
        return;
      }

      final distanceKm = RadiusCalculate.calculateDistance(
        latitude ?? 0.0,
        longitude ?? 0.0,
        latitudePoint,
        longitudePoint,
      );

      if (distanceKm > radiusPoint &&
          (attendanceType == 'location_based_only' ||
              attendanceType == 'hybrid')) {
        _showOutOfAreaDialog(distance: distanceKm, allowedRadius: radiusPoint);
        return;
      }

      _navigateToAttendance(attendanceType, isCheckIn, idSchedule);
    } catch (e) {
      _showModernDialog(
          'Error', 'Terjadi kesalahan: $e', Icons.error_rounded, Colors.red);
    }
  }

  Future<void> _navigateToAttendance(
      String attendanceType, bool isCheckIn, String idSchedule) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceDetectorCheckinPage(
          isCheckedIn: isCheckIn,
          latitude: latitude,
          longitude: longitude,
          idSchedule: idSchedule,
        ),
      ),
    );
    if (mounted) {
      context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());
    }
  }

  Widget _buildModernAttendanceButton({
    required bool isCheckIn,
    required bool isDisabledButton,
    required VoidCallback onPressed,
  }) {
    final String label = isCheckIn ? 'Check In' : 'Check Out';
    final IconData icon =
        isCheckIn ? Icons.login_rounded : Icons.logout_rounded;

    final LinearGradient gradient = isCheckIn
        ? const LinearGradient(colors: [Color(0xFFDFF5E7), Color(0xFFD2F0DE)])
        : const LinearGradient(colors: [Color(0xFFFDEADF), Color(0xFFF9E3D5)]);

    final LinearGradient disabledGradient =
        const LinearGradient(colors: [Color(0xFFF0F2F7), Color(0xFFE9ECF4)]);

    final Color textColor =
        isCheckIn ? const Color(0xFF1F8B4D) : const Color(0xFFFE600B);
    final Color containerColor =
        isCheckIn ? const Color(0xFF1F8B4D) : const Color(0xFFFE600B);

    return GestureDetector(
      onTap: isDisabledButton ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDisabledButton ? disabledGradient : gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 1),
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
                color:
                    isDisabledButton ? const Color(0xFFA1A9C3) : containerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SpaceHeight(8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDisabledButton ? const Color(0xFFA1A9C3) : textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showModernDialog(
      String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SpaceHeight(16),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SpaceHeight(8),
              Text(message,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              const SpaceHeight(24),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterFaceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Registrasi Wajah Diperlukan',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SpaceHeight(12),
              Text('Anda belum mendaftarkan wajah. Daftarkan sekarang?',
                  textAlign: TextAlign.center),
              const SpaceHeight(24),
              Row(
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Nanti')),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(const RegisterFacePage());
                    },
                    child: const Text('Registrasi'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFakeGpsDialog() {}
  void _showOutOfAreaDialog(
      {required double distance, required double allowedRadius}) {}

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SpaceWidth(4),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildModernButtonCuti(
      {required IconData icon,
      required String label,
      required String subtitle,
      required LinearGradient gradient,
      required VoidCallback onPressed}) {
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

  Widget _buildModernButtonLembur(
      {required IconData icon,
      required String label,
      required String subtitle,
      required LinearGradient gradient,
      required VoidCallback onPressed}) {
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
                    color: const Color(0xFF0059FF).withOpacity(0.15),
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

  Widget _buildModernButtonPengaduan(
      {required IconData icon,
      required String label,
      required String subtitle,
      required LinearGradient gradient,
      required VoidCallback onPressed}) {
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

  Widget _buildModernButtonLibur(
      {required IconData icon,
      required String label,
      required String subtitle,
      required LinearGradient gradient,
      required VoidCallback onPressed}) {
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
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width * 0.20, size.height, size.width * 0.45, size.height - 20);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 50, size.width, size.height - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
