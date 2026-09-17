import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/create_izin/create_izin_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/provider/izin_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';

class AddIzinPage extends StatefulWidget {
  const AddIzinPage({super.key});

  @override
  State<AddIzinPage> createState() => _AddIzinPageState();
}

class _AddIzinPageState extends State<AddIzinPage> {
  bool _isLoadingSubmit = false;

  Future<void> _selectDate(
      BuildContext context, IzinProvider provider, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      if (isStartDate) {
        provider.setDates(picked, provider.endDate);
      } else {
        provider.setDates(provider.startDate, picked);
      }
    }
  }

  void _showAttachmentOptions(BuildContext context, IzinProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 20.h),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        Text(
                          'Pilih Sumber Lampiran',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.photo_library_rounded,
                                color: AppColors.primary, size: 20.r),
                          ),
                          title: Text('Galeri Foto',
                              style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text('Ambil gambar dari galeri handphone',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp, color: AppColors.grey)),
                          onTap: () async {
                            Navigator.pop(context);
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              provider.setAttachment(image.path, image.name);
                            }
                          },
                        ),
                        SizedBox(height: 4.h),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.camera_alt_rounded,
                                color: AppColors.primary, size: 20.r),
                          ),
                          title: Text('Kamera',
                              style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text('Ambil foto langsung dari kamera',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp, color: AppColors.grey)),
                          onTap: () async {
                            Navigator.pop(context);
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera);
                            if (image != null) {
                              provider.setAttachment(image.path, image.name);
                            }
                          },
                        ),
                        SizedBox(height: 4.h),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.insert_drive_file_rounded,
                                color: AppColors.primary, size: 20.r),
                          ),
                          title: Text('File Dokumen',
                              style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              'Pilih PDF, Word, atau Gambar (Termasuk WebP)',
                              style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp, color: AppColors.grey)),
                          onTap: () async {
                            Navigator.pop(context);
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'pdf',
                                'doc',
                                'docx',
                                'png',
                                'jpg',
                                'jpeg',
                                'webp'
                              ],
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              provider.setAttachment(result.files.single.path!,
                                  result.files.single.name);
                            }
                          },
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitIzinRequest(IzinProvider provider) {
    if (!provider.isIzinFormValid()) return;

    final String startDateStr =
        DateFormat('yyyy-MM-dd').format(provider.startDate!);
    final String? endDateStr = provider.endDate != null
        ? DateFormat('yyyy-MM-dd').format(provider.endDate!)
        : null;
    final String inputAtStr =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    context.read<CreateIzinBloc>().add(
          CreateIzinEvent.createIzin(
            inputAt: inputAtStr,
            alasanIzin:
                provider.selectedAlasanIzin ?? 'Keperluan Mendesak Lainnya',
            tanggalIzin: startDateStr,
            description: provider.descriptionController.text.trim(),
            typeDay: provider.typeDay,
            endDate: provider.typeDay == 1 ? null : endDateStr,
            attachment: provider.selectedFile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IzinProvider>();

    final String startText = provider.startDate != null
        ? DateFormat('dd MMM yyyy').format(provider.startDate!)
        : '';
    final String endText = provider.endDate != null
        ? DateFormat('dd MMM yyyy').format(provider.endDate!)
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A49B7),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                _buildHeader(context, provider),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.r),
                        topRight: Radius.circular(28.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.r),
                        topRight: Radius.circular(28.r),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Alasan Izin'),
                            SizedBox(height: 8.h),
                            _buildReasonDropdown(provider),
                            SizedBox(height: 16.h),
                            _buildSectionTitle('Type Izin'),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<int>(
                              value: provider.typeDay,
                              style: GoogleFonts.poppins(
                                  fontSize: 12.5.sp, color: Colors.black),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                              ),
                              items: [
                                DropdownMenuItem(
                                    value: 1,
                                    child: Text('Single Day',
                                        style: TextStyle(fontSize: 12.5.sp))),
                                DropdownMenuItem(
                                    value: 2,
                                    child: Text('Multiple Day',
                                        style: TextStyle(fontSize: 12.5.sp))),
                              ],
                              onChanged: (value) {
                                if (value != null) provider.setTypeDay(value);
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildSectionTitle('Rentang Tanggal'),
                            SizedBox(height: 8.h),
                            _buildDateFields(
                                context, provider, startText, endText),
                            SizedBox(height: 16.h),
                            _buildSectionTitle('Deskripsi'),
                            SizedBox(height: 8.h),
                            _buildDescriptionField(provider),
                            SizedBox(height: 16.h),
                            _buildSectionTitle('Lampiran (Optional)'),
                            SizedBox(height: 8.h),
                            _buildAttachmentField(context, provider),
                            SizedBox(height: 24.h),
                            _buildSubmitButton(provider),
                            SizedBox(height: 10.h),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, IzinProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              provider.resetForm();
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Ajukan Izin Anda',
            style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black));
  }

  Widget _buildDateFields(BuildContext context, IzinProvider provider,
      String startText, String endText) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, provider, true),
            child: IgnorePointer(
              child: TextField(
                controller: TextEditingController(text: startText),
                style: GoogleFonts.poppins(fontSize: 12.sp),
                decoration: InputDecoration(
                  labelText:
                      provider.typeDay == 1 ? 'Tanggal Izin' : 'Start Date',
                  labelStyle: GoogleFonts.poppins(fontSize: 11.5.sp),
                  prefixIcon: Icon(Icons.event, size: 18.r),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                ),
              ),
            ),
          ),
        ),
        if (provider.typeDay == 2) ...[
          SizedBox(width: 10.w),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, provider, false),
              child: IgnorePointer(
                child: TextField(
                  controller: TextEditingController(text: endText),
                  style: GoogleFonts.poppins(fontSize: 12.sp),
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    labelStyle: GoogleFonts.poppins(fontSize: 11.5.sp),
                    prefixIcon: Icon(Icons.event_available, size: 18.r),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReasonDropdown(IzinProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedAlasanIzin,
      hint: Text('-pilih alasan izin-',
          style: GoogleFonts.poppins(fontSize: 12.sp)),
      style: GoogleFonts.poppins(fontSize: 12.5.sp, color: Colors.black),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      items: provider.alasanIzinOption.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: GoogleFonts.poppins(fontSize: 12.5.sp)),
        );
      }).toList(),
      onChanged: (newValue) {
        provider.setSelectedAlasanIzin(newValue);
      },
    );
  }

  Widget _buildDescriptionField(IzinProvider provider) {
    return TextField(
      controller: provider.descriptionController,
      maxLines: 3,
      style: GoogleFonts.poppins(fontSize: 12.sp),
      decoration: InputDecoration(
        hintText: 'Tulis detail deskripsi izin...',
        hintStyle: GoogleFonts.poppins(fontSize: 11.5.sp, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.all(12.r),
      ),
    );
  }

  Widget _buildAttachmentField(BuildContext context, IzinProvider provider) {
    final bool isImage = provider.selectedFileName != null &&
        ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
            .contains(provider.selectedFileName!.split('.').last.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showAttachmentOptions(context, provider),
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
                color: AppColors.light.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r)),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_rounded,
                    color: AppColors.primary, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    provider.selectedFileName ??
                        'Pilih file lampiran (PDF/Gambar)',
                    style: GoogleFonts.poppins(fontSize: 11.5.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (provider.selectedFileName != null)
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.red, size: 18.r),
                    onPressed: () => provider.removeAttachment(),
                  )
              ],
            ),
          ),
        ),
        if (provider.selectedFile != null && isImage) ...[
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.file(
              provider.selectedFile!,
              height: 140.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(IzinProvider provider) {
    final bool valid = provider.isIzinFormValid();

    return BlocConsumer<CreateIzinBloc, CreateIzinState>(
      listener: (context, state) {
        state.maybeWhen(
          loading: () {
            setState(() {
              _isLoadingSubmit = true;
            });
          },
          success: (message) {
            setState(() {
              _isLoadingSubmit = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(message, style: GoogleFonts.poppins(fontSize: 12.sp)),
                backgroundColor: AppColors.green,
              ),
            );
            provider.resetForm();
            Navigator.pop(context);
          },
          error: (errorMessage) {
            setState(() {
              _isLoadingSubmit = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage,
                    style: GoogleFonts.poppins(fontSize: 12.sp)),
                backgroundColor: AppColors.red,
              ),
            );
          },
          orElse: () {
            setState(() {
              _isLoadingSubmit = false;
            });
          },
        );
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: valid ? AppColors.primary : Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
            onPressed: (_isLoadingSubmit || !valid)
                ? null
                : () => _submitIzinRequest(provider),
            child: _isLoadingSubmit
                ? SizedBox(
                    height: 18.r,
                    width: 18.r,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Ajukan Permohonan Izin',
                    style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
          ),
        );
      },
    );
  }
}
