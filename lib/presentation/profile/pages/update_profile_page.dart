import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/response/user_response_model.dart';
import '../bloc/get_user/get_user_bloc.dart';
import '../bloc/update_user/update_user_bloc.dart';

class UpdateProfilePage extends StatefulWidget {
  final UserResponseModel? user;

  const UpdateProfilePage({super.key, this.user});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  XFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          imageFile = picked;
        });
      }
    } catch (e) {
      debugPrint("Gagal memilih gambar: $e");
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title:
                  Text('Galeri', style: GoogleFonts.poppins(fontSize: 13.sp)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title:
                  Text('Kamera', style: GoogleFonts.poppins(fontSize: 13.sp)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitUpdate() {
    // Validasi form password jika salah satu diisi
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    final bool isChangingPassword =
        oldPass.isNotEmpty || newPass.isNotEmpty || confirmPass.isNotEmpty;

    if (isChangingPassword) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    } else if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Pilih foto avatar baru atau masukkan kata sandi baru.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Sesuaikan dengan signature event di UpdateUserBloc Anda
    // Contoh pemanggilan umum:
    // context.read<UpdateUserBloc>().add(
    //   UpdateUserEvent.updateProfile(
    //     avatar: imageFile,
    //     oldPassword: oldPass.isNotEmpty ? oldPass : null,
    //     newPassword: newPass.isNotEmpty ? newPass : null,
    //   ),
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menyimpan perubahan...'),
        backgroundColor: Color(0xFF007BFF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Account',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SEKSI AVATAR ---
                Text(
                  'Avatar',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _showImageSourceDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9ECEF),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                            side: BorderSide(
                                color: Colors.grey.shade400, width: 0.8),
                          ),
                        ),
                        child: Text(
                          'Choose File',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          imageFile != null
                              ? imageFile!.name
                              : 'No file chosen',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: imageFile != null
                                ? Colors.black87
                                : Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Image.file(
                            File(imageFile!.path),
                            width: 32.r,
                            height: 32.r,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (widget.user?.avatar != null &&
                          widget.user!.avatar!.startsWith('http'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Image.network(
                            widget.user!.avatar!,
                            width: 32.r,
                            height: 32.r,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),
                Divider(thickness: 1, color: Colors.grey.shade300),
                SizedBox(height: 14.h),

                // --- SEKSI CHANGE PASSWORD ---
                Text(
                  'Change Password',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 14.h),

                // Old Password
                _buildPasswordField(
                  controller: oldPasswordController,
                  label: 'Old Password',
                  hint: 'Old Password',
                  obscureText: _obscureOldPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                  validator: (val) {
                    if ((newPasswordController.text.isNotEmpty ||
                            confirmPasswordController.text.isNotEmpty) &&
                        (val == null || val.isEmpty)) {
                      return 'Masukkan kata sandi lama Anda';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),

                // New Password
                _buildPasswordField(
                  controller: newPasswordController,
                  label: 'New Password',
                  hint: 'New Password',
                  obscureText: _obscureNewPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: (val) {
                    if (oldPasswordController.text.isNotEmpty &&
                        (val == null || val.isEmpty)) {
                      return 'Masukkan kata sandi baru';
                    }
                    if (val != null && val.isNotEmpty && val.length < 6) {
                      return 'Minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),

                // Confirm Password
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (val) {
                    if (newPasswordController.text.isNotEmpty &&
                        val != newPasswordController.text) {
                      return 'Konfirmasi kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2B5E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.5.sp,
              color: Colors.grey[400],
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF007BFF)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[500],
                size: 18.r,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
      ],
    );
  }
}
