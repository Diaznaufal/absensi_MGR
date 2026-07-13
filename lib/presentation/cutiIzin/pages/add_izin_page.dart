import 'dart:io';
import 'package:flutter/material.dart';
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
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, provider),
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
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Alasan Izin'),
                          const SpaceHeight(12),
                          _buildReasonDropdown(provider),
                          const SpaceHeight(24),
                          _buildSectionTitle('Type Izin'),
                          const SpaceHeight(12),
                          DropdownButtonFormField<int>(
                            value: provider.typeDay,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 1, child: Text('Single Day')),
                              DropdownMenuItem(
                                  value: 2, child: Text('Multiple Day')),
                            ],
                            onChanged: (value) {
                              if (value != null) provider.setTypeDay(value);
                            },
                          ),
                          const SpaceHeight(24),
                          _buildSectionTitle('Rentang Tanggal'),
                          const SpaceHeight(12),
                          _buildDateFields(
                              context, provider, startText, endText),
                          const SpaceHeight(24),
                          _buildSectionTitle('Deskripsi'),
                          const SpaceHeight(12),
                          _buildDescriptionField(provider),
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

  Widget _buildHeader(BuildContext context, IzinProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              provider.resetForm();
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
            'Ajukan Izin Anda',
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
                decoration: InputDecoration(
                  labelText:
                      provider.typeDay == 1 ? 'Tanggal Izin' : 'Start Date',
                  prefixIcon: const Icon(Icons.event),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
        if (provider.typeDay == 2) ...[
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
                      borderRadius: BorderRadius.circular(12),
                    ),
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
      hint: Text('-pilih alasan izin-', style: GoogleFonts.poppins()),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: provider.alasanIzinOption.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
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
      decoration: InputDecoration(
        hintText: 'Tulis detail deskripsi izin...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                content: Text(message, style: GoogleFonts.poppins()),
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
                content: Text(errorMessage, style: GoogleFonts.poppins()),
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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: valid ? AppColors.primary : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: (_isLoadingSubmit || !valid)
                ? null
                : () => _submitIzinRequest(provider),
            child: _isLoadingSubmit
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Ajukan Permohonan Izin',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
          ),
        );
      },
    );
  }
}