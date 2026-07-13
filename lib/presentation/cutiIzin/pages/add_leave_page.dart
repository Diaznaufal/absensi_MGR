import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../provider/leave_provider.dart';
import '../bloc/create_leave/create_leave_bloc.dart';

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

  void _submitLeaveRequest(LeaveProvider provider) {
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

    final String startDateStr =
        DateFormat('yyyy-MM-dd').format(provider.startDate!);
        
    // 🌟 PERBAIKAN: Jika endDate di provider null (Single Day), langsung set null tanpa memformat!
    final String? endDateStr = provider.endDate != null
        ? DateFormat('yyyy-MM-dd').format(provider.endDate!)
        : null;

    final String inputAtStr =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Membungkus Jenis Cuti dan Deskripsi Alasan ke kolom description BE
    final String fullDescription =
        '[${provider.selectedLeaveType}] - ${provider.reasonController.text.trim()}';

    context.read<CreateLeaveBloc>().add(
          CreateLeaveEvent.createLeave(
            inputAt: inputAtStr,
            totalDays: provider.totalDays,
            type: provider.typeDay,
            leaveTypeId: provider.selectedLeaveType == 'Cuti Tahunan' ? 1 : 2,
            startDate: startDateStr,
            endDate: provider.typeDay == 1 ? null : endDateStr,
            reason: fullDescription,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();

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
                    borderRadius: const BorderRadius.only(
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
                          _buildSectionTitle('Type Cuti'),
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
                          if (provider.startDate != null) ...[
                            const SpaceHeight(16),
                            Text(
                              'Total Hari Cuti: ${provider.totalDays} Hari',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                          const SpaceHeight(24),
                          _buildSectionTitle('Alasan'),
                          const SpaceHeight(12),
                          _buildReasonField(provider),
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
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 22),
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
          if (type.toLowerCase().contains('tahunan'))
            quotaText = 'Kuota 12 hari';
          if (type.toLowerCase().contains('sakit')) quotaText = 'Kuota 30 hari';

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
                  labelText:
                      provider.typeDay == 1 ? 'Tanggal Cuti' : 'Start Date',
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
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildSubmitButton(LeaveProvider provider) {
    final bool valid = provider.isFormValid();

    return BlocConsumer<CreateLeaveBloc, CreateLeaveState>(
      listener: (context, state) {
        state.maybeWhen(
          loading: () => setState(() => _isLoadingSubmit = true),
          success: (message) {
            setState(() => _isLoadingSubmit = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(message), backgroundColor: AppColors.green),
            );
            provider.resetForm();
            Navigator.pop(context);
          },
          error: (errorMessage) {
            setState(() => _isLoadingSubmit = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(errorMessage), backgroundColor: AppColors.red),
            );
          },
          orElse: () => setState(() => _isLoadingSubmit = false),
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
                : () => _submitLeaveRequest(provider),
            child: _isLoadingSubmit
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Ajukan Permohonan Cuti',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
          ),
        );
      },
    );
  }
}