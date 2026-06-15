import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../provider/leave_provider.dart';

class AddLeavePage extends StatefulWidget {
  const AddLeavePage({super.key});

  @override
  State<AddLeavePage> createState() => _AddLeavePageState();
}

class _AddLeavePageState extends State<AddLeavePage> {
  bool _isLoadingSubmit = false;

  Future<void> _selectDate(
      BuildContext context, LeaveProvider provider, bool isStartDate) async {
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

  // --- Fungsi Baru: Bottom Sheet Opsi Lampiran ---
  void _showAttachmentOptions(BuildContext context, LeaveProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pilih Sumber Lampiran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SpaceHeight(20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.primary),
                  ),
                  title: Text('Galeri Foto',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text('Ambil gambar dari galeri handphone',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.grey)),
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      provider.setAttachment(image.path, image.name);
                    }
                  },
                ),
                const SpaceHeight(8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.primary),
                  ),
                  title: Text('Kamera',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text('Ambil foto langsung dari kamera',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.grey)),
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      provider.setAttachment(image.path, image.name);
                    }
                  },
                ),
                const SpaceHeight(8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.insert_drive_file_rounded,
                        color: AppColors.primary),
                  ),
                  title: Text('File Dokumen',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text('Pilih PDF, Word, atau Gambar (Termasuk WebP)',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.grey)),
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
                    if (result != null && result.files.single.path != null) {
                      provider.setAttachment(
                          result.files.single.path!, result.files.single.name);
                    }
                  },
                ),
                const SpaceHeight(12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitLeaveRequest(LeaveProvider provider) async {
    if (!provider.isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap lengkapi semua kolom dengan benar',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingSubmit = true;
    });

    // Simulasi loading hit jaringan
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      provider.tambahCuti();
      setState(() {
        _isLoadingSubmit = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request submitted successfully!',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    // Sinkronisasi teks tanggal display
    final String startText = provider.startDate != null
        ? DateFormat('dd MMM yyyy').format(provider.startDate!)
        : '';
    final String endText = provider.endDate != null
        ? DateFormat('dd MMM yyyy').format(provider.endDate!)
        : '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Jenis Cuti'),
                          const SpaceHeight(12),
                          _buildLeaveTypeSelector(provider),
                          const SpaceHeight(24),
                          _buildSectionTitle('Rentang Tangal'),
                          const SpaceHeight(12),
                          _buildDateFields(
                              context, provider, startText, endText),
                          const SpaceHeight(24),
                          _buildSectionTitle('Alasan'),
                          const SpaceHeight(12),
                          _buildReasonField(provider),
                          const SpaceHeight(24),
                          _buildSectionTitle('Lampiran (Optional)'),
                          const SpaceHeight(12),
                          _buildAttachmentField(context, provider),
                          const SpaceHeight(32),
                          _buildSubmitButton(provider),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SpaceWidth(12),
          Text(
            'Ajukan Cuti Anda',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black));
  }

  Widget _buildLeaveTypeSelector(LeaveProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.light.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light.withOpacity(0.5)),
      ),
      child: Column(
        children: provider.leaveTypes.map((type) {
          final isSelected = type == provider.selectedLeaveType;
          final icon = provider.getLeaveIcon(type);

          String? quotaText;
          if (type.toLowerCase().contains('annual'))
            quotaText = '12 days quota';
          if (type.toLowerCase().contains('sick')) quotaText = '30 days quota';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => provider.setSelectedLeaveType(type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.light.withOpacity(0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.light.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                          color: isSelected ? Colors.white : AppColors.grey,
                          size: 20),
                    ),
                    const SpaceWidth(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.black,
                            ),
                          ),
                          if (quotaText != null)
                            Text(quotaText,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 24),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateFields(BuildContext context, LeaveProvider provider,
      String startText, String endText) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, provider, true),
            child: IgnorePointer(
              child: TextField(
                controller: TextEditingController(text: startText),
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: const Icon(Icons.event),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
        const SpaceWidth(16),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, provider, false),
            child: IgnorePointer(
              child: TextField(
                controller: TextEditingController(text: endText),
                decoration: InputDecoration(
                  labelText: 'End Date',
                  prefixIcon: const Icon(Icons.event_available),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField(LeaveProvider provider) {
    return TextField(
      controller: provider.reasonController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Tulis alasan cuti...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- Perbaikan Metode: Dialihkan Menuju Bottom Sheet & Menampilkan Preview Foto ---
  Widget _buildAttachmentField(BuildContext context, LeaveProvider provider) {
    final bool isImage = provider.selectedFileName != null &&
        ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
            .contains(provider.selectedFileName!.split('.').last.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showAttachmentOptions(
              context, provider), // Mengaktifkan bottom sheet opsi
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.light.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload_rounded,
                    color: AppColors.primary),
                const SpaceWidth(12),
                Expanded(
                  child: Text(
                    provider.selectedFileName ??
                        'Pilih file lampiran (PDF/Gambar)',
                    style: GoogleFonts.poppins(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (provider.selectedFileName != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.red),
                    onPressed: () => provider.removeAttachment(),
                  )
              ],
            ),
          ),
        ),
        // Menampilkan image preview lokal jika file terpilih adalah format gambar
        if (provider.selectedFile != null && isImage) ...[
          const SpaceHeight(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              provider.selectedFile!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(LeaveProvider provider) {
    final bool valid = provider.isFormValid();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: valid ? AppColors.primary : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: (_isLoadingSubmit || !valid)
            ? null
            : () => _submitLeaveRequest(provider),
        child: _isLoadingSubmit
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text('Submit Leave Request',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
      ),
    );
  }
}
