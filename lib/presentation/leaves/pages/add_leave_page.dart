import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/create_leave/create_leave_bloc.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/leave_type/leave_type_bloc.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/leave_balance/leave_balance_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/core.dart';

class AddLeavePage extends StatefulWidget {
  const AddLeavePage({super.key});

  @override
  State<AddLeavePage> createState() => _AddLeavePageState();
}

class _AddLeavePageState extends State<AddLeavePage> {
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  late final TextEditingController reasonController;

  int? selectedLeaveTypeId;
  File? selectedFile;
  String? selectedFileName;

  @override
  void initState() {
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    reasonController = TextEditingController();
    super.initState();
    // Fetch leave types and balance when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaveTypeBloc>().add(const LeaveTypeEvent.getLeaveTypes());
        context
            .read<LeaveBalanceBloc>()
            .add(const LeaveBalanceEvent.getLeaveBalance());
      }
    });
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
        selectedFileName = image.name;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
        selectedFileName = image.name;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        selectedFileName = result.files.single.name;
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Choose Attachment',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SpaceHeight(20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Pick an image from gallery',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                const SpaceHeight(8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Take a photo with camera',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                const SpaceHeight(8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Document',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Pick a PDF or Word document',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                ),
                const SpaceHeight(16),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatDate(DateTime date) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    return dateFormatter.format(date);
  }

  String formatDisplayDate(DateTime date) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    return dateFormatter.format(date);
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = formatDisplayDate(picked);
      });
    }
  }

  void _submitLeaveRequest() {
    if (selectedLeaveTypeId == null ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all required fields',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    // Parse the display dates back to DateTime for formatting
    final startDate = DateFormat('dd MMM yyyy').parse(startDateController.text);
    final endDate = DateFormat('dd MMM yyyy').parse(endDateController.text);

    context.read<CreateLeaveBloc>().add(
          CreateLeaveEvent.createLeave(
            leaveTypeId: selectedLeaveTypeId!,
            startDate: formatDate(startDate),
            endDate: formatDate(endDate),
            reason: reasonController.text,
            attachment: selectedFile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CreateLeaveBloc, CreateLeaveState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            success: (response) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    response,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Leave Type'),
                          const SpaceHeight(12),
                          _buildLeaveTypeSelector(),
                          const SpaceHeight(24),
                          _buildSectionTitle('Date Range'),
                          const SpaceHeight(12),
                          _buildDateFields(context),
                          const SpaceHeight(24),
                          _buildSectionTitle('Reason'),
                          const SpaceHeight(12),
                          _buildReasonField(),
                          const SpaceHeight(24),
                          _buildSectionTitle('Attachment (Optional)'),
                          const SpaceHeight(12),
                          _buildAttachmentField(),
                          const SpaceHeight(32),
                          _buildSubmitButton(),
                        ],
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
                  'Apply for Leave',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Submit your leave request',
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

  Widget _buildLeaveTypeSelector() {
    return BlocBuilder<LeaveTypeBloc, LeaveTypeState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildLoadingLeaveTypes(),
          loading: () => _buildLoadingLeaveTypes(),
          success: (response) {
            final leaveTypes = response.data ?? [];
            if (leaveTypes.isEmpty) {
              return _buildEmptyLeaveTypes();
            }
            // Auto-select first leave type if none selected
            if (selectedLeaveTypeId == null && leaveTypes.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    selectedLeaveTypeId = leaveTypes.first.id;
                  });
                }
              });
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.light.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.light.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: leaveTypes.map((type) {
                  final isSelected = type.id == selectedLeaveTypeId;
                  final icon = _getLeaveTypeIcon(type.name ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedLeaveTypeId = type.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.light.withValues(alpha: 0.5),
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
                                    : AppColors.light.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected ? Colors.white : AppColors.grey,
                                size: 20,
                              ),
                            ),
                            const SpaceWidth(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.name ?? 'Unknown',
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
                                  if (type.quotaDays != null)
                                    Text(
                                      '${type.quotaDays} days quota',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          error: (message) => _buildErrorLeaveTypes(message),
        );
      },
    );
  }

  IconData _getLeaveTypeIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('annual') || lowerName.contains('vacation')) {
      return Icons.beach_access_rounded;
    } else if (lowerName.contains('sick')) {
      return Icons.local_hospital_rounded;
    } else if (lowerName.contains('emergency')) {
      return Icons.emergency_rounded;
    } else if (lowerName.contains('unpaid')) {
      return Icons.money_off_rounded;
    }
    return Icons.event_note_rounded;
  }

  Widget _buildLoadingLeaveTypes() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.light.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyLeaveTypes() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.light.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'No leave types available',
          style: GoogleFonts.poppins(color: AppColors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorLeaveTypes(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Failed to load leave types',
            style: GoogleFonts.poppins(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SpaceHeight(8),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: AppColors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            context,
            controller: startDateController,
            label: 'Start Date',
            icon: Icons.event_rounded,
          ),
        ),
        const SpaceWidth(16),
        Expanded(
          child: _buildDateField(
            context,
            controller: endDateController,
            label: 'End Date',
            icon: Icons.event_available_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.grey,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary),
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
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: reasonController,
      maxLines: 4,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Explain the reason for your leave request...',
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.grey.withOpacity(0.6),
        ),
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

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showAttachmentOptions,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.light.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.light.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.attachment_rounded,
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
                        selectedFileName ?? 'No file selected',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: selectedFileName != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selectedFileName != null
                              ? AppColors.black
                              : AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SpaceHeight(4),
                      Text(
                        'Tap to choose file (Image or PDF)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.grey.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedFileName != null)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedFile = null;
                        selectedFileName = null;
                      });
                    },
                  )
                else
                  const Icon(
                    Icons.cloud_upload_rounded,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
        if (selectedFile != null && _isImageFile(selectedFileName!)) ...[
          const SpaceHeight(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              selectedFile!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  bool _isImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<CreateLeaveBloc, CreateLeaveState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: isLoading ? null : _submitLeaveRequest,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Submit Leave Request',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
