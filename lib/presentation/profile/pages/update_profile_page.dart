import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

// Import komponen internal Anda
import '../../../core/core.dart';
import '../../../core/components/image_picker_widget.dart';

class UpdateProfilePage extends StatefulWidget {
  final User user;
  const UpdateProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Controllers untuk Personal Details
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  // Controllers untuk Emergency Contact
  late TextEditingController emergencyNameController;
  late TextEditingController emergencyRelationController;
  late TextEditingController emergencyPhoneController;

  XFile? imageFile;
  final Color primaryColor = const Color(0xFF1955AF);

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data yang ada atau mock data sesuai gambar
    nameController =
        TextEditingController(text: widget.user.name ?? 'John Doe');
    emailController =
        TextEditingController(text: widget.user.email ?? 'johndoe@example.com');
    phoneController =
        TextEditingController(text: widget.user.phone ?? '081234567890');
    addressController = TextEditingController(
        text: 'Jl. Merdeka No. 123, Kecamatan Sukajadi, Kota Bandung, 40111');

    emergencyNameController = TextEditingController(text: 'Ibu Jane Doe');
    emergencyRelationController = TextEditingController(text: 'Ibu');
    emergencyPhoneController = TextEditingController(text: '081298765432');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emergencyNameController.dispose();
    emergencyRelationController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SpaceHeight(10),
                        _buildProfilePictureSection(),
                        const SpaceHeight(20),
                        _buildPersonalDetailsSection(),
                        const SpaceHeight(20),
                        _buildEmergencyContactSection(),
                        const SpaceHeight(
                            120), // Memberi ruang untuk tombol bawah
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Button (Fixed)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _buildSubmitButton(),
            ),
          ),
        ],
      ),
    );
  }

  // Header sesuai gambar dengan tombol back boxy
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SpaceWidth(20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Update your personal information',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Foto Profil
  Widget _buildProfilePictureSection() {
    return _buildCardWrapper(
      icon: Icons.camera_alt_rounded,
      title: 'Profile Picture',
      subtitle: 'Upload or update your profile photo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Profile Image',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          const SpaceHeight(12),
          Row(
            children: [
              // Preview Box
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            Image.network(imageFile!.path, fit: BoxFit.cover),
                      )
                    : Icon(Icons.image_outlined,
                        color: Colors.grey[400], size: 40),
              ),
              const SpaceWidth(20),
              // Button Pilih Foto
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) setState(() => imageFile = image);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Pilih Foto',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Detail Personal
  Widget _buildPersonalDetailsSection() {
    return _buildCardWrapper(
      icon: Icons.person_rounded,
      title: 'Personal Details',
      subtitle: 'Update your personal information',
      child: Column(
        children: [
          _buildTextField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          _buildTextField(
            controller: emailController,
            label: 'Email Address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            controller: phoneController,
            label: 'Phone Number',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(
            controller: addressController,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // Section Kontak Darurat
  Widget _buildEmergencyContactSection() {
    return _buildCardWrapper(
      icon: Icons.phone_in_talk_rounded,
      title: 'Emergency Contact',
      subtitle: 'Update your emergency contact',
      child: Column(
        children: [
          _buildTextField(
            controller: emergencyNameController,
            label: 'Contact Name',
            icon: Icons.person_outline_rounded,
          ),
          _buildTextField(
            controller: emergencyRelationController,
            label: 'Relationship',
            icon: Icons.people_outline_rounded,
          ),
          _buildTextField(
            controller: emergencyPhoneController,
            label: 'Contact Number',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // Komponen Reusable untuk Card
  Widget _buildCardWrapper({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SpaceWidth(15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[900])),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  // Komponen Reusable untuk Text Field sesuai desain gambar
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
          const SpaceHeight(8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800]),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: primaryColor, size: 20),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Submit di bagian bawah
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Tambahkan logika update bloc Anda di sini
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Updated Successfully!')),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_rounded,
                color: Colors.white, size: 20),
            const SpaceWidth(10),
            Text(
              'Update Profile (UI Preview)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
