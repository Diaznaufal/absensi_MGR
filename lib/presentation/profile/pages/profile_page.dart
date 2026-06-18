import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these exist in your project structure
import '../../../core/core.dart';
import 'update_profile_page.dart';
// If structure changed, just ensure you create a valid User object for push.
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import '../../auth/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set a consistent light grey background color for the screen
    final backgroundColor = Color(0xBAE7E8EC);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
        toolbarHeight: -10,
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Full Screen Gradient Background
          // 2. Main Content inside SafeArea and MediaQuery handling
          SafeArea(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: Column(
                children: [
                  // --- Custom Header ---
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(),
                  ),

                  // --- Scrollable Content Area ---
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Column(
                            children: [
                              // --- New Avatar Card ---
                              _buildAvatarCard(
                                name: "John Doe",
                                position: "Senior Flutter Developer",
                                department: "IT Department",
                                status: "Karyawan Tetap",
                              ),

                              SizedBox(height: 16),

                              // --- Data Karyawan Card ---
                              _buildEmployeeDataCard(),

                              SizedBox(height: 16),

                              // --- Informasi Kontak Card ---
                              _buildContactInfoCard(),

                              SizedBox(height: 32),

                              // --- Edit Profile Button (Centered) ---
                              _buildEditProfileButton(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Implementation ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A49B7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Saya',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Kelola informasi akun Anda',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          // Logout Button
          _buildHeaderButton(
            icon: Icons.edit_outlined,
            onPressed: () {
              context.push(UpdateProfilePage(
                user: User(
                  id: 1,
                  name: "John Doe",
                  email: "johndoe@example.com",
                  phone: "081234567890",
                  imageUrl: null,
                ),
              ));
            },
          ),
        ],
      ),
    );
  }

  // Common Header Button Style
  Widget _buildHeaderButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  // --- New Avatar Card Implementation ---
  Widget _buildAvatarCard({
    required String name,
    required String position,
    required String department,
    required String status,
  }) {
    final primaryColor = const Color(0xFF1955AF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[100],
              child: Icon(
                Icons.person_rounded,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
          ),
          SizedBox(width: 10),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                // Position Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EDFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    position,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Department with Icon
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Icon(Icons.business_outlined,
                          size: 14, color: Colors.grey[500]),
                      SizedBox(width: 6),
                      Text(
                        department,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Data Karyawan Card Implementation ---
  Widget _buildEmployeeDataCard() {
    return _buildInfoCard(
      icon: Icons.badge_outlined,
      title: 'Data Karyawan',
      children: [
        _buildInfoRow(
          icon: Icons.badge_outlined,
          label: 'NIK Karyawan',
          value: 'EMP12345678',
        ),
        _buildInfoRow(
          icon: Icons.work_outline_rounded,
          label: 'Jabatan',
          value: 'Senior Flutter Developer',
        ),
        _buildInfoRow(
          icon: Icons.business_outlined,
          label: 'Divisi',
          value: 'IT Department',
        ),
        _buildInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal Masuk',
          value: '01 Januari 2023',
        ),
      ],
    );
  }

  // --- Informasi Kontak Card Implementation ---
  Widget _buildContactInfoCard() {
    return _buildInfoCard(
      icon: Icons.contact_mail_outlined,
      title: 'Informasi Kontak',
      children: [
        _buildInfoRow(
          icon: Icons.phone_outlined,
          label: 'Nomor HP',
          value: '081234567890',
        ),
        _buildInfoRow(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: 'johndoe@example.com',
        ),
        _buildInfoRow(
          icon: Icons.location_on_outlined,
          label: 'Alamat',
          value: 'Jl. Merdeka No. 123, Kecamatan Sukajadi, Kota Bandung, 40111',
          isLongText: true,
        ),
        _buildInfoRow(
          icon: Icons.contact_phone_outlined,
          label: 'Kontak Darurat',
          value: 'Ibu Jane Doe (081298765432)',
          isLongText: true,
        ),
      ],
    );
  }

  // --- Common Info Card Style ---
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final primaryColor = const Color(0xFF1955AF);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Card Rows
          ...children,
        ],
      ),
    );
  }

  // --- Common Info Row Style (Modified to match image) ---
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isStatus = false,
    bool isLongText = false,
    Color? valueColor,
  }) {
    final rowPadding = isStatus ? 10.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: rowPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF1955AF),
            ),
          ),
          SizedBox(width: 10),
          // Label text
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          // Value text or Status Badge
          Expanded(
            flex: isLongText ? 2 : 0,
            child: isStatus
                ? _buildStatusBadge(value, valueColor!)
                : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.end,
                    maxLines: isLongText ? 3 : 1,
                    overflow: isLongText
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  // Green Status Badge Style
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // --- Centered Edit Profile Button Style ---
  Widget _buildEditProfileButton(BuildContext context) {
    final primaryColor = const Color(0xFF1955AF);

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity, // Set fixed width
        height: 52,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showLogoutDialog(),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Logout',
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
      ),
    );
  }

  // --- Common Space Helpers ---
  // (Assuming these might already exist in context.spaceWidth etc. or create them)
  // Widget SpaceWidth(double width) => SizedBox(width: width);
  // Widget SpaceHeight(double height) => SizedBox(height: height);

  // Re-creating helpers if core.dart doesn't provide the exact name
  Widget SpaceWidth(double width) => SizedBox(width: width);
  Widget SpaceHeight(double height) => SizedBox(height: height);

  // --- Common Dialogs ---
  void _showLogoutDialog() {
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
              // Red Logout Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Confirm Logout',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to logout from your account?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: _buildDialogButton(
                      text: 'Cancel',
                      color: Colors.grey[100]!,
                      textColor: Colors.grey[700]!,
                      onPressed: () => Navigator.pop(context),
                      hasBorder: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Logout Button
                  Expanded(
                    child: _buildDialogButton(
                      text: 'Logout',
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                        context.pushReplacement(const LoginPage());
                      },
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

  // Common Dialog Button Style
  Widget _buildDialogButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
