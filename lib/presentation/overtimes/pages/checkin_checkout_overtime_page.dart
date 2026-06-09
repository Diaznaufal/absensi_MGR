import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/start_overtime/start_overtime_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/end_overtime/end_overtime_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../core/core.dart';

class CheckInCheckOutOvertimePage extends StatefulWidget {
  final bool isCheckIn;
  final int? overtimeId;
  final Overtime? overtimeData;

  const CheckInCheckOutOvertimePage({
    super.key,
    required this.isCheckIn,
    this.overtimeId,
    this.overtimeData,
  });

  @override
  State<CheckInCheckOutOvertimePage> createState() =>
      _CheckInCheckOutOvertimePageState();
}

class _CheckInCheckOutOvertimePageState
    extends State<CheckInCheckOutOvertimePage> {
  late final TextEditingController notesController;
  late final TextEditingController reasonController;
  XFile? selectedDocument;

  @override
  void initState() {
    notesController = TextEditingController();
    reasonController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    notesController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      developer.log('📸 Original file picked', name: 'OvertimePage');
      developer.log('Path: ${pickedFile.path}', name: 'OvertimePage');

      // Get file size
      final originalFile = File(pickedFile.path);
      final originalSize = await originalFile.length();
      developer.log(
        'Original size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB',
        name: 'OvertimePage',
      );

      // Compress image to JPG and < 2MB
      final compressedFile = await _compressImage(pickedFile);

      if (compressedFile != null) {
        final compressedSize = await compressedFile.length();
        developer.log(
          'Compressed size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
          name: 'OvertimePage',
        );

        // Check if still > 2MB
        if (compressedSize > 2 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'File masih terlalu besar setelah dikompress. Pilih gambar lain.',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppColors.red,
              ),
            );
          }
          return;
        }

        // Convert File to XFile
        final compressedXFile = XFile(compressedFile.path);

        setState(() {
          selectedDocument = compressedXFile;
        });

        developer.log('✅ Image compressed successfully', name: 'OvertimePage');
      }
    } catch (e) {
      developer.log('Error picking/compressing image: $e', name: 'OvertimePage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memproses gambar: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<File?> _compressImage(XFile imageFile) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'overtime_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      developer.log('🔄 Compressing image...', name: 'OvertimePage');

      // Compress with quality 85, format JPG
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        developer.log('❌ Compression failed', name: 'OvertimePage');
        return null;
      }

      final resultFile = File(result.path);
      final fileSize = await resultFile.length();

      // If still > 2MB, compress with lower quality
      if (fileSize > 2 * 1024 * 1024) {
        developer.log(
          '⚠️ Still > 2MB, compressing with quality 70...',
          name: 'OvertimePage',
        );

        final targetPath2 = path.join(
          tempDir.path,
          'overtime_${DateTime.now().millisecondsSinceEpoch}_q70.jpg',
        );

        final result2 = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath2,
          quality: 70,
          format: CompressFormat.jpeg,
        );

        if (result2 != null) {
          return File(result2.path);
        }
      }

      return resultFile;
    } catch (e) {
      developer.log('Error compressing image: $e', name: 'OvertimePage');
      return null;
    }
  }

  Future<void> _showOvertimeConfirmationDialog({
    required bool isCheckIn,
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final now = DateTime.now();
        final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
        final timeFormatter = DateFormat('HH:mm');
        final confirmationLabel = isCheckIn ? 'Waktu Mulai' : 'Waktu Selesai';
        final confirmationValue = isCheckIn
            ? DateFormat('HH:mm:ss').format(now)
            : timeFormatter.format(now);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCheckIn
                      ? AppColors.green.withValues(alpha: 0.1)
                      : AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                  color: isCheckIn ? AppColors.green : AppColors.red,
                  size: 24,
                ),
              ),
              const SpaceWidth(12),
              Expanded(
                child: Text(
                  'Konfirmasi ${isCheckIn ? "Mulai" : "Selesai"} Lembur',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin ${isCheckIn ? "memulai" : "mengakhiri"} lembur?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SpaceHeight(16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    if (isCheckIn) ...[
                      _buildOvertimeConfirmationRow(
                        icon: Icons.notes_rounded,
                        label: 'Alasan',
                        value: reasonController.text,
                        color: Colors.orange,
                      ),
                      if (notesController.text.isNotEmpty) ...[
                        const SpaceHeight(8),
                        _buildOvertimeConfirmationRow(
                          icon: Icons.description_rounded,
                          label: 'Catatan',
                          value: notesController.text,
                          color: Colors.purple,
                        ),
                      ],
                      if (selectedDocument != null) ...[
                        const SpaceHeight(8),
                        _buildOvertimeConfirmationRow(
                          icon: Icons.attach_file_rounded,
                          label: 'Dokumen',
                          value: 'Terpilih',
                          color: AppColors.primary,
                        ),
                      ],
                    ] else ...[
                      _buildOvertimeConfirmationRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Tanggal',
                        value: widget.overtimeData?.date != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID')
                                .format(DateTime.parse(widget.overtimeData!.date!))
                            : '-',
                        color: AppColors.primary,
                      ),
                      const SpaceHeight(8),
                      _buildOvertimeConfirmationRow(
                        icon: Icons.login_rounded,
                        label: 'Waktu Mulai',
                        value: widget.overtimeData?.startTime ?? '-',
                        color: AppColors.green,
                      ),
                    ],
                    const SpaceHeight(8),
                    _buildOvertimeConfirmationRow(
                      icon: Icons.schedule_rounded,
                      label: confirmationLabel,
                      value: confirmationValue,
                      color: isCheckIn ? AppColors.green : AppColors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckIn ? AppColors.green : AppColors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Ya, Lanjutkan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirm();
    }
  }

  Widget _buildOvertimeConfirmationRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SpaceWidth(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SpaceHeight(2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (widget.isCheckIn) {
      // Validate required field: Reason for check-in
      if (reasonController.text.trim().isEmpty) {
        developer.log(
          '❌ Validation Failed: Reason is empty',
          name: 'CheckInCheckOutOvertimePage',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reason is required',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      // Show confirmation dialog before submitting
      _showOvertimeConfirmationDialog(
        isCheckIn: true,
        onConfirm: () {
          // Log form data before submission
          developer.log(
            '📝 START OVERTIME - Form Data:',
            name: 'CheckInCheckOutOvertimePage',
          );
          developer.log(
            'Reason: "${reasonController.text}"',
            name: 'CheckInCheckOutOvertimePage',
          );
          developer.log(
            'Notes: ${notesController.text.isEmpty ? "null" : "\"${notesController.text}\""}',
            name: 'CheckInCheckOutOvertimePage',
          );
          developer.log(
            'Document: ${selectedDocument != null ? selectedDocument!.name : "null"}',
            name: 'CheckInCheckOutOvertimePage',
          );
          if (selectedDocument != null) {
            developer.log(
              'Document Path: ${selectedDocument!.path}',
              name: 'CheckInCheckOutOvertimePage',
            );
          }

          context.read<StartOvertimeBloc>().add(
                StartOvertimeEvent.startOvertime(
                  notes:
                      notesController.text.isEmpty ? null : notesController.text,
                  reason: reasonController.text,
                  startDocumentPath: selectedDocument,
                ),
              );
        },
      );
    } else {
      // Check out - no form validation, just submit
      if (widget.overtimeId == null) {
        developer.log(
          '❌ Validation Failed: Overtime ID is null',
          name: 'CheckInCheckOutOvertimePage',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Overtime ID is required',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      // Show confirmation dialog before submitting
      _showOvertimeConfirmationDialog(
        isCheckIn: false,
        onConfirm: () {
          // Log before submission
          developer.log(
            '📝 END OVERTIME - Data:',
            name: 'CheckInCheckOutOvertimePage',
          );
          developer.log(
            'Overtime ID: ${widget.overtimeId}',
            name: 'CheckInCheckOutOvertimePage',
          );

          // Submit without reason parameter
          context.read<EndOvertimeBloc>().add(
                EndOvertimeEvent.endOvertime(
                  id: widget.overtimeId!,
                ),
              );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<StartOvertimeBloc, StartOvertimeState>(
            listener: (context, state) {
              state.when(
                initial: () {},
                loading: () {},
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Overtime started successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.red,
                    ),
                  );
                },
              );
            },
          ),
          BlocListener<EndOvertimeBloc, EndOvertimeState>(
            listener: (context, state) {
              state.when(
                initial: () {},
                loading: () {},
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Overtime ended successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.red,
                    ),
                  );
                },
              );
            },
          ),
        ],
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 1.0],
              colors: [
                Color(0xFF1e3c72),
                Color(0xFF2a5298),
                Colors.white,
              ],
            ),
          ),
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
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: widget.isCheckIn
                          ? _buildCheckInForm()
                          : _buildCheckOutInfo(),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SpaceWidth(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCheckIn ? 'Start Overtime' : 'End Overtime',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.isCheckIn
                      ? 'Record your overtime start'
                      : 'Record your overtime end',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Reason (Required) - Always first
        _buildSectionTitle('Reason *'),
        const SpaceHeight(12),
        _buildReasonField(),

        // 2. Document (Optional)
        const SpaceHeight(24),
        _buildSectionTitle('Document (Optional)'),
        const SpaceHeight(12),
        _buildDocumentPicker(),

        // 3. Notes (Optional)
        const SpaceHeight(24),
        _buildSectionTitle('Notes (Optional)'),
        const SpaceHeight(12),
        _buildNotesField(),

        const SpaceHeight(32),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildCheckOutInfo() {
    final dateFormatter = DateFormat('EEE, dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Single card with all information
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.light.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1e3c72), Color(0xFF3b82c9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SpaceWidth(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overtime Information',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Review before ending',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SpaceHeight(16),
              const Divider(height: 1),
              const SpaceHeight(16),

              // Compact info rows
              _buildCompactInfoRow(
                'Date',
                widget.overtimeData?.date != null
                    ? dateFormatter
                        .format(DateTime.parse(widget.overtimeData!.date!))
                    : '-',
                Icons.calendar_today_rounded,
                AppColors.primary,
              ),
              const SpaceHeight(12),
              _buildCompactInfoRow(
                'Start Time',
                widget.overtimeData?.startTime ?? '-',
                Icons.login_rounded,
                AppColors.green,
              ),
              const SpaceHeight(12),
              _buildCompactInfoRow(
                'Reason',
                widget.overtimeData?.reason ?? '-',
                Icons.notes_rounded,
                Colors.orange,
              ),

              // Notes (if available)
              if (widget.overtimeData?.notes != null &&
                  widget.overtimeData!.notes!.isNotEmpty) ...[
                const SpaceHeight(12),
                _buildCompactInfoRow(
                  'Notes',
                  widget.overtimeData!.notes!,
                  Icons.description_rounded,
                  Colors.purple,
                ),
              ],

              // Document (if available)
              if (widget.overtimeData?.document != null &&
                  widget.overtimeData!.document!.isNotEmpty) ...[
                const SpaceHeight(12),
                _buildCompactInfoRow(
                  'Document',
                  'Uploaded',
                  Icons.attach_file_rounded,
                  AppColors.primary,
                  showCheckIcon: true,
                ),
              ],
            ],
          ),
        ),

        const SpaceHeight(32),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildCompactInfoRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool showCheckIcon = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SpaceWidth(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SpaceHeight(2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (showCheckIcon)
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.green,
            size: 18,
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: notesController,
      maxLines: 3,
      maxLength: 255,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Add any notes about this overtime...',
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.grey.withOpacity(0.6),
        ),
        helperText: 'Optional - Maximum 255 characters',
        helperStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey),
        filled: true,
        fillColor: AppColors.light.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.light.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.light.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: reasonController,
      maxLines: 3,
      maxLength: 255,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Explain the reason for overtime...',
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.grey.withOpacity(0.6),
        ),
        helperText: 'Required - Maximum 255 characters',
        helperStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey),
        filled: true,
        fillColor: AppColors.light.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.light.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.light.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return InkWell(
      onTap: _pickDocument,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.light.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.light.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.attach_file_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SpaceWidth(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDocument != null
                        ? 'Document Selected'
                        : 'Select Document',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  if (selectedDocument != null)
                    Text(
                      selectedDocument!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'JPG/PNG (auto-compressed to <2MB)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              selectedDocument != null
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_rounded,
              color: selectedDocument != null
                  ? AppColors.green
                  : AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<StartOvertimeBloc, StartOvertimeState>(
      builder: (context, startState) {
        return BlocBuilder<EndOvertimeBloc, EndOvertimeState>(
          builder: (context, endState) {
            final isLoading = (widget.isCheckIn &&
                    startState.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    )) ||
                (!widget.isCheckIn &&
                    endState.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ));

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.isCheckIn ? AppColors.green : AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        widget.isCheckIn
                            ? Icons.login_rounded
                            : Icons.logout_rounded,
                        size: 20,
                      ),
                label: Text(
                  widget.isCheckIn ? 'Start Overtime' : 'End Overtime',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
