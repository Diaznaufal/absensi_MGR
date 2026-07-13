import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Pastikan import path di bawah ini disesuaikan dengan struktur folder proyek Anda
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_absensi_app/presentation/profile/pages/update_profile_page.dart';
import 'package:flutter_absensi_app/presentation/profile/bloc/get_user/get_user_bloc.dart';
import 'package:flutter_absensi_app/data/models/response/user_response_model.dart';

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
        toolbarHeight: 60,
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kelola informasi akun Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {},
              child: Icon(
                Icons.edit,
                color: Colors.white,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
              ),
              success: (user) {
                // Objek 'user' di sini bertipe UserResponseModel
                final employee = user.employee;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SpaceHeight(16),

                        // --- CARD 1: PROFILE BRIEF (DATA DINAMIS) ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: user.avatar != null &&
                                        user.avatar!.isNotEmpty
                                    ? NetworkImage(user.avatar!)
                                    : null,
                                child:
                                    user.avatar == null || user.avatar!.isEmpty
                                        ? Icon(Icons.person,
                                            size: 44, color: Colors.grey[400])
                                        : null,
                              ),
                              const SpaceWidth(16),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SpaceHeight(2),
                                    Text(
                                      user.roleLabel ?? 'Karyawan',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Color(0xFF0A49B7),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SpaceHeight(10),
                                    Row(
                                      children: [
                                        _buildBadge(
                                            // Menampilkan ID Divisi dari relasi employee
                                            employee?.namePosition ?? '-',
                                            const Color(0xFFF0F4F8),
                                            Colors.grey[700]!),
                                        const SpaceWidth(8),
                                        _buildBadge(
                                            // Menampilkan ID Divisi dari relasi employee
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

                        const SpaceHeight(16),

                        // --- CARD 2: DATA KARYAWAN (DATA DINAMIS) ---
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                  Icons.badge_outlined, 'Data Karyawan'),
                              const Divider(
                                height: 24,
                                thickness: 1,
                                color: Colors.black26,
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

                        const SpaceHeight(16),

                        // --- CARD 3: INFORMASI KONTAK (DATA DINAMIS) ---
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(Icons.contact_phone_outlined,
                                  'Informasi Kontak'),
                              const Divider(
                                height: 24,
                                thickness: 1,
                                color: Colors.black26,
                              ),
                              _buildRowItem('Nomor HP', employee?.noHp ?? '-',
                                  'assets/icons/phone_outline.svg'),
                              _buildRowItem('Email', user.email ?? '-',
                                  'assets/icons/emailOutline.svg'),
                              _buildRowItem(
                                  'Alamat',
                                  employee?.fullAddress ??
                                      '-', // Tempat lahir digunakan sementara sebagai data alamat jika kolom alamat terpisah belum ada
                                  'assets/icons/locationOutline.svg'),
                            ],
                          ),
                        ),

                        const SpaceHeight(24),

                        // --- BUTTON LOGOUT ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C54BE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              _showLogoutDialog();
                            },
                            icon: const Icon(Icons.logout,
                                color: Colors.white, size: 20),
                            label: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SpaceHeight(15),
                      ],
                    ),
                  ),
                );
              },
              orElse: () => const Center(
                child: Text('Memuat data profil...'),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C54BE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SpaceWidth(12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
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
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xff0c54be).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4)),
                child: SvgPicture.asset(
                  svgPath,
                  width: 18,
                  height: 17,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0C54BE),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SpaceWidth(10),
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 5)
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 22,
            thickness: 1,
            color: Colors.black12,
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Anda?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
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
