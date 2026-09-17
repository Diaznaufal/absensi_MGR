import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/profile/pages/update_profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import path disesuaikan dengan struktur folder proyek
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_absensi_app/presentation/profile/bloc/get_user/get_user_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Memicu bloc untuk mengambil data profil saat halaman pertama kali dibuka
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: 56.h,
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Saya',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kelola informasi akun Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                final state = context.read<GetUserBloc>().state;
                final user = state.maybeWhen(
                  success: (u) => u,
                  orElse: () => null,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateProfilePage(
                      user: user,
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 20.r,
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<GetUserBloc, GetUserState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (message) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.poppins(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
              ),
              success: (user) {
                final employee = user.employee;

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        SizedBox(height: 14.h),

                        // --- CARD 1: PROFILE BRIEF (DATA DINAMIS) ---
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32.r,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: (user.avatar != null &&
                                        user.avatar!.isNotEmpty &&
                                        user.avatar!.startsWith(
                                            'http')) // 🛡️ Hanya panggil jika URL HTTP valid
                                    ? NetworkImage(user.avatar!)
                                    : null,
                                child: (user.avatar == null ||
                                        user.avatar!.isEmpty ||
                                        !user.avatar!.startsWith('http'))
                                    ? Text(
                                        user.name != null &&
                                                user.name!.isNotEmpty
                                            ? user.name!.trim()[0].toUpperCase()
                                            : 'U',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name != null && user.name!.isNotEmpty
                                          ? user.name!
                                              .split(' ')
                                              .take(2)
                                              .join(' ')
                                          : '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      user.roleLabel ?? 'Karyawan',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11.5.sp,
                                          color: const Color(0xFF0A49B7),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 8.h),
                                    Wrap(
                                      spacing: 6.w,
                                      runSpacing: 4.h,
                                      children: [
                                        _buildBadge(
                                            employee?.namePosition ?? '-',
                                            const Color(0xFFF0F4F8),
                                            Colors.grey[700]!),
                                        _buildBadge(
                                            getEmployeeType(
                                                employee?.typeEmployee),
                                            const Color(0xFFF0F8F2),
                                            Colors.green[600]!),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // --- CARD 2: DATA KARYAWAN (DATA DINAMIS) ---
                        Container(
                          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                  Icons.badge_outlined, 'Data Karyawan'),
                              Divider(
                                height: 20.h,
                                thickness: 1,
                                color: Colors.black12,
                              ),
                              _buildRowItem('NIP', employee?.nip ?? '-',
                                  'assets/icons/personCard.svg'),
                              _buildRowItem(
                                  'Jabatan',
                                  employee?.namePosition ?? '-',
                                  'assets/icons/workoutline.svg'),
                              _buildRowItem(
                                  'Divisi',
                                  employee?.nameDivision ?? '-',
                                  'assets/icons/building.svg'),
                              _buildRowItem(
                                  'Tanggal Masuk',
                                  employee?.dateIn ?? '-',
                                  'assets/icons/calendarStart.svg',
                                  isLast: true),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // --- CARD 3: INFORMASI KONTAK (DATA DINAMIS) ---
                        Container(
                          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(Icons.contact_phone_outlined,
                                  'Informasi Kontak'),
                              Divider(
                                height: 20.h,
                                thickness: 1,
                                color: Colors.black12,
                              ),
                              _buildRowItem('Nomor HP', employee?.noHp ?? '-',
                                  'assets/icons/phone_outline.svg'),
                              _buildRowItem('Email', user.email ?? '-',
                                  'assets/icons/emailOutline.svg'),
                              _buildRowItem(
                                  'Alamat',
                                  employee?.fullAddress ?? '-',
                                  'assets/icons/locationOutline.svg',
                                  isLast: true),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // --- BUTTON LOGOUT ---
                        SizedBox(
                          width: double.infinity,
                          height: 46.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C54BE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              _showLogoutDialog();
                            },
                            icon: Icon(Icons.logout,
                                color: Colors.white, size: 18.r),
                            label: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: 10
                                .h), // Extra padding bawah agar tidak tertutup BottomNavBar
                      ],
                    ),
                  ),
                );
              },
              orElse: () => Center(
                child: Text(
                  'Memuat data profil...',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: const Color(0xFF0C54BE),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.white, size: 18.r),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRowItem(String label, String value, String svgPath,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                    color: const Color(0xff0c54be).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4.r)),
                child: SvgPicture.asset(
                  svgPath,
                  width: 16.r,
                  height: 16.r,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0C54BE),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 16.h,
            thickness: 1,
            color: Colors.black12,
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: Text(
          'Konfirmasi Logout',
          style:
              GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Anda?',
          style: GoogleFonts.poppins(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthLocalDatasource().removeAuthData();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getEmployeeType(String? type) {
    switch (type) {
      case '1':
        return 'Kontrak';
      case '2':
        return 'Magang';
      case '3':
        return 'Tetap';
      default:
        return '-';
    }
  }
}
