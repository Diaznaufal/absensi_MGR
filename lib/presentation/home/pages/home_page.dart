import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
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

  // Stream untuk melacak pergerakan GPS secara real-time
  StreamSubscription<Position>? _positionStream;

  DateTime? _parseTimeString(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  // Variable & Timer untuk Jam Real-time
  late Timer _clockTimer;
  late DateTime _currentTime;

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

    _currentTime = DateTime.now();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    _initializeAnimations();
    _initializeFaceEmbedding();

    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());
    context.read<GetAllLeavesBloc>().add(GetAllLeavesEvent.getAllLeaves());

    initLocationTracking();
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
    _positionStream?.cancel();
    _clockTimer.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> initLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Layanan lokasi dinonaktifkan.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Ambil lokasi cache terlebih dahulu agar tidak null sesaat
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        setState(() {
          latitude = lastKnown.latitude;
          longitude = lastKnown.longitude;
        });
      }

      // Ambil posisi presisi saat ini
      try {
        Position initialPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        if (mounted) {
          setState(() {
            latitude = initialPos.latitude;
            longitude = initialPos.longitude;
          });
        }
      } catch (e) {
        debugPrint('Gagal fetch current position instan: $e');
      }

      // Pasang stream continuous tracking
      await _positionStream?.cancel();
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (mounted) {
            setState(() {
              latitude = position.latitude;
              longitude = position.longitude;
            });
            debugPrint(
                'GPS Updated: ${position.latitude}, ${position.longitude}');
          }
        },
        onError: (e) {
          debugPrint('Error pada Location Stream: $e');
        },
      );
    } catch (e) {
      debugPrint('Error menginisialisasi pelacakan lokasi: $e');
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
    await initLocationTracking();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;
    final bool isVerySmallDevice = size.width < 340;
    final double horizontalPadding =
        isTablet ? 20.w : (isVerySmallDevice ? 10.w : 14.w);

    // Padding bottom header yang cukup untuk menampung overlap card
    final double headerBottomPadding = isTablet ? 90.h : 80.h;
    final double cardTopOffset = isTablet ? 120.h : 110.h;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF0A49B7),
      ),
      body: SafeArea(
        child: Center(
          // Membatasi lebar konten agar di tablet tidak melar berlebihan
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 30.h),
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
                                    horizontalPadding,
                                  ),
                                );
                              },
                              orElse: () {
                                if (_lastUser != null) {
                                  return _buildHeader(
                                    headerBottomPadding,
                                    _lastUser!,
                                    horizontalPadding,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                        Positioned(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: cardTopOffset,
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
                    // Jarak pemisah dinamis setelah header stack
                    SizedBox(height: isTablet ? 90.h : 80.h),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildMenuGrid(size),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      double bottomPadding, UserResponseModel user, double horizontalPadding) {
    final employee = user.employee;
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
            horizontalPadding, 14.h, horizontalPadding, bottomPadding),
        decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: const Color(0xA1B8BBBE),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.r),
                    child: Center(
                      child: (user.avatar != null &&
                              user.avatar!.isNotEmpty &&
                              user.avatar!.startsWith('http'))
                          ? Image.network(
                              user.avatar!,
                              width: 50.r,
                              height: 50.r,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    user.name != null && user.name!.isNotEmpty
                                        ? user.name!.trim()[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18.sp,
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
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                SpaceWidth(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        user.name != null && user.name!.isNotEmpty
                            ? user.name!.split(' ').take(2).join(' ')
                            : '',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
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
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.push(const NotifikasiPage());
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Badge(
                      offset: Offset(6.w, -6.h),
                      backgroundColor: Colors.red,
                      label: Text("3", style: TextStyle(fontSize: 10.sp)),
                      textColor: Colors.white,
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 24.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SpaceHeight(14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
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
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFE5E9F4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2D78).withOpacity(0.08),
                blurRadius: 16.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8A94B4),
                          ),
                        ),
                        SpaceHeight(2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _currentTime.toFormattedTime(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 28.sp,
                              color: const Color(0xFF1B2D78),
                              height: 1.0,
                            ),
                          ),
                        ),
                        SpaceHeight(2.h),
                        Text(
                          _currentTime.toFormattedDate(),
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: const Color(0xFF8A94B4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48.h,
                    color: const Color(0xFFE2E6F3),
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jam kerja',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8A94B4),
                          ),
                        ),
                        SpaceHeight(2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$jadwalClockIn-$jadwalClockOut',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: const Color(0xFF1B2D78),
                            ),
                          ),
                        ),
                        SpaceHeight(2.h),
                        Text(
                          shiftName,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
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
              Divider(thickness: 1, height: 18.h),
              if (alreadyCheckedIn)
                Text(
                  'Anda sudah Check In pukul: $checkInJam. Checkout aktif 10 mnt sebelum $jadwalClockOut',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.redAccent,
                  ),
                )
              else if (isDayOff)
                Text(
                  'Hari ini jadwal Day Off anda. Selamat beristirahat!',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.redAccent,
                  ),
                )
              else if (isCuti)
                Text(
                  'Hari ini anda sedang mengambil masa Cuti',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.redAccent,
                  ),
                )
              else
                Text(
                  'Belum ada riwayat Absen. Check In aktif 1 jam sebelum jam masuk.',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuGrid(Size screenSize) {
    final bool isWide = screenSize.width >= 550;
    final int crossAxisCount = isWide ? 4 : 2;

    // Rasio aspek disesuaikan agar tinggi container pas dan simetris
    final double quickActionAspectRatio = isWide ? 1.35 : 1.35;
    final double serviceCardAspectRatio = isWide ? 1.28 : 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B2D78),
          ),
        ),
        SpaceHeight(10.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: quickActionAspectRatio,
          children: [
            _buildAttendanceButton(isCheckIn: true),
            _buildAttendanceButton(isCheckIn: false),
          ],
        ),
        SpaceHeight(16.h),
        Text(
          'Layanan Karyawan',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B2D78),
          ),
        ),
        SpaceHeight(10.h),
        // Menggunakan GridView agar semua kartu Layanan Karyawan otomatis seragam tingginya
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: serviceCardAspectRatio,
          children: [
            _buildReusableMenuCard(
              icon: Icons.event_busy_rounded,
              label: 'Izin / Cuti',
              subtitle: 'Ajukan izin atau cuti',
              themeColor: const Color(0xFFFF4D67),
              bgColor: const Color(0xFFFFE5EA),
              onPressed: () => context.push(const LeavePage()),
            ),
            _buildReusableMenuCard(
              icon: Icons.more_time_rounded,
              label: 'Lembur',
              subtitle: 'Ajukan lembur kerja',
              themeColor: const Color(0xFF0059FF),
              bgColor: const Color(0xFFDCE7FF),
              onPressed: () => context.push(const OvertimePage()),
            ),
            _buildReusableMenuCard(
              icon: Icons.campaign_rounded,
              label: 'Pengaduan',
              subtitle: 'Pengaduan perusahaan',
              themeColor: const Color(0xFFE59400),
              bgColor: const Color(0xFFFFEDB8),
              onPressed: () => context.push(PengaduanPage()),
            ),
            _buildReusableMenuCard(
              icon: Icons.calendar_month_rounded,
              label: 'Libur Karyawan',
              subtitle: 'Kelola jadwal libur',
              themeColor: const Color(0xFF7E3AF2),
              bgColor: const Color(0xFFE8D8FF),
              onPressed: () => context.push(LiburkaryawanPage()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceButton({required bool isCheckIn}) {
    return BlocBuilder<IsCheckedinBloc, IsCheckedinState>(
      builder: (context, checkedInState) {
        final Map<String, dynamic> absenceTodayData = checkedInState.maybeWhen(
          success: (absenceData) =>
              absenceData is Map<String, dynamic> ? absenceData : {},
          orElse: () => {},
        );

        final String? polygonRaw = absenceTodayData['polygon']?.toString();
        final bool hasSchedule = absenceTodayData['has_schedule'] == true;
        final bool alreadyCheckedIn =
            absenceTodayData['already_checked_in'] == true;
        final String idScheduleApi =
            absenceTodayData['id_schedule']?.toString() ?? '';
        final String statusLabel =
            absenceTodayData['status_label']?.toString() ?? '';
        final String currentStatus =
            absenceTodayData['status']?.toString() ?? '';

        final bool isDayOff = statusLabel == 'Day Off' || currentStatus == '2';
        final bool isCuti = statusLabel == 'Cuti' || currentStatus == '4';

        final Map<String, dynamic> workshift =
            absenceTodayData['workshift'] is Map
                ? Map<String, dynamic>.from(
                    absenceTodayData['workshift'] as Map,
                  )
                : {};

        final String rawClockIn = workshift['clock_in']?.toString() ?? '';
        final String rawClockOut = workshift['clock_out']?.toString() ?? '';

        final DateTime? scheduleClockIn = _parseTimeString(rawClockIn);
        final DateTime? scheduleClockOut = _parseTimeString(rawClockOut);

        final DateTime now = _currentTime;

        bool isDisabled = true;

        if (!hasSchedule || isDayOff || isCuti) {
          isDisabled = true;
        } else if (isCheckIn) {
          if (!alreadyCheckedIn && scheduleClockIn != null) {
            final DateTime checkInWindowStart =
                scheduleClockIn.subtract(const Duration(hours: 1));
            isDisabled = now.isBefore(checkInWindowStart);
          } else {
            isDisabled = true;
          }
        } else {
          if (alreadyCheckedIn && scheduleClockOut != null) {
            final DateTime checkOutWindowStart =
                scheduleClockOut.subtract(const Duration(minutes: 10));
            isDisabled = now.isBefore(checkOutWindowStart);
          } else {
            isDisabled = true;
          }
        }

        return _buildModernAttendanceButton(
          isCheckIn: isCheckIn,
          isDisabledButton: isDisabled,
          onPressed: () => _handleAttendance(
            isCheckIn: isCheckIn,
            idSchedule: idScheduleApi,
            polygonRaw: polygonRaw,
          ),
        );
      },
    );
  }

  Future<void> _handleAttendance({
    required bool isCheckIn,
    required String idSchedule,
    required String? polygonRaw,
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

      if (latitude == null || longitude == null) {
        try {
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
          latitude = pos.latitude;
          longitude = pos.longitude;
        } catch (e) {
          Position? lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            latitude = lastKnown.latitude;
            longitude = lastKnown.longitude;
          }
        }
      }

      if (latitude == null || longitude == null) {
        if (mounted) {
          _showModernDialog(
            'Lokasi Belum Siap',
            'Sedang mencari sinyal GPS. Pastikan GPS aktif dengan akurasi tinggi lalu coba kembali.',
            Icons.location_off_rounded,
            Colors.orange,
          );
        }
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 3),
        );
        if (position.isMocked) {
          _showFakeGpsDialog();
          return;
        }
      } catch (_) {}

      final List<List<double>> polygonPoints =
          RadiusCalculate.parsePolygon(polygonRaw);

      if (polygonPoints.isNotEmpty) {
        final bool isInside = RadiusCalculate.isPointInPolygon(
          latitude!,
          longitude!,
          polygonPoints,
          toleranceMeters: 30.0,
        );

        if (!isInside) {
          if (mounted) {
            _showOutOfAreaDialog();
          }
          return;
        }
      }

      _navigateToAttendance('polygon_based', isCheckIn, idSchedule);
    } catch (e) {
      if (mounted) {
        _showModernDialog(
          'Error',
          'Terjadi kesalahan: $e',
          Icons.error_rounded,
          Colors.red,
        );
      }
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
      initLocationTracking();
      context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());
    }
  }

  void _showOutOfAreaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  color: Colors.red,
                  size: 36.r,
                ),
              ),
              SpaceHeight(16.h),
              Text(
                'Absensi Gagal',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SpaceHeight(8.h),
              Text(
                'Anda berada di luar area lokasi kantor yang telah ditentukan.',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SpaceHeight(20.h),
              SizedBox(
                width: double.infinity,
                height: 42.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Mengerti',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAttendanceButton({
    required bool isCheckIn,
    required bool isDisabledButton,
    required VoidCallback onPressed,
  }) {
    final String label = isCheckIn ? 'Check In' : 'Check Out';
    final IconData icon =
        isCheckIn ? Icons.login_rounded : Icons.logout_rounded;

    final Color themeColor =
        isCheckIn ? const Color(0xFF1F8B4D) : const Color(0xFFFE600B);
    final Color bgColor =
        isCheckIn ? const Color(0xFFE3F7EB) : const Color(0xFFFEECE0);

    return InkWell(
      onTap: isDisabledButton ? null : onPressed,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: isDisabledButton ? const Color(0xFFEBEFF5) : bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2D78).withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color:
                      isDisabledButton ? const Color(0xFFA1A9C3) : themeColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 22.r),
              ),
              SpaceHeight(8.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDisabledButton ? const Color(0xFFA1A9C3) : themeColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReusableMenuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color themeColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2D78).withOpacity(0.05),
              blurRadius: 6.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Kotak Atas
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 22.r),
            ),

            // Bagian Bawah: Judul, Subtitle & Icon Panah
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SpaceHeight(4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sisi Kiri: Subtitle
                    Expanded(
                      flex: 65,
                      child: Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 35,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10.r,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50.r)),
                child: Icon(icon, color: color, size: 28.r),
              ),
              SpaceHeight(14.h),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SpaceHeight(6.h),
              Text(message,
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              SpaceHeight(20.h),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text('OK', style: GoogleFonts.poppins(fontSize: 12.sp)))
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Registrasi Wajah Diperlukan',
                  style: GoogleFonts.poppins(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SpaceHeight(10.h),
              Text('Anda belum mendaftarkan wajah. Daftarkan sekarang?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12.sp)),
              SpaceHeight(20.h),
              Row(
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Nanti',
                          style: GoogleFonts.poppins(fontSize: 12.sp))),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(const RegisterFacePage());
                    },
                    child: Text('Registrasi',
                        style: GoogleFonts.poppins(fontSize: 12.sp)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFakeGpsDialog() {
    _showModernDialog(
      'Aplikasi Terlarang',
      'Terdeteksi penggunaan lokasi palsu (Fake GPS). Harap matikan aplikasi terkait untuk melanjutkan.',
      Icons.security,
      Colors.red,
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white),
          SpaceWidth(4.w),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 35);
    path.quadraticBezierTo(
        size.width * 0.20, size.height, size.width * 0.45, size.height - 18);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 45, size.width, size.height - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
