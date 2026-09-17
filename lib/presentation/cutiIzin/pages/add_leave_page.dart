import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              style: GoogleFonts.poppins(fontSize: 12.sp)),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final String startDateStr =
        DateFormat('yyyy-MM-dd').format(provider.startDate!);

    final String? endDateStr = provider.endDate != null
        ? DateFormat('yyyy-MM-dd').format(provider.endDate!)
        : null;

    final String inputAtStr =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

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
      backgroundColor: const Color(0xFF0A49B7),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                _buildHeader(context),
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
                            _buildSectionTitle('Jenis Cuti'),
                            SizedBox(height: 8.h),
                            _buildLeaveTypeSelector(provider),
                            SizedBox(height: 16.h),
                            _buildSectionTitle('Type Cuti'),
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
                            if (provider.startDate != null) ...[
                              SizedBox(height: 10.h),
                              Text(
                                'Total Hari Cuti: ${provider.totalDays} Hari',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            SizedBox(height: 16.h),
                            _buildSectionTitle('Alasan'),
                            SizedBox(height: 8.h),
                            _buildReasonField(provider),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pop(context),
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
            'Ajukan Cuti Anda',
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

  Widget _buildLeaveTypeSelector(LeaveProvider provider) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.light.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.light.withOpacity(0.5)),
      ),
      child: Column(
        children: provider.leaveTypes.map((type) {
          final isSelected = type == provider.selectedLeaveType;
          final icon = provider.getLeaveIcon(type);

          String? quotaText;
          if (type.toLowerCase().contains('tahunan')) {
            quotaText = 'Kuota 12 hari';
          }
          if (type.toLowerCase().contains('sakit')) {
            quotaText = 'Kuota 30 hari';
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: InkWell(
              onTap: () => provider.setSelectedLeaveType(type),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.light.withOpacity(0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.light.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(icon,
                          color: isSelected ? Colors.white : AppColors.grey,
                          size: 18.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5.sp,
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
                                    fontSize: 10.5.sp, color: AppColors.grey)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20.r),
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
                style: GoogleFonts.poppins(fontSize: 12.sp),
                decoration: InputDecoration(
                  labelText:
                      provider.typeDay == 1 ? 'Tanggal Cuti' : 'Start Date',
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
                        borderRadius: BorderRadius.circular(10.r)),
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

  Widget _buildReasonField(LeaveProvider provider) {
    return TextField(
      controller: provider.reasonController,
      maxLines: 3,
      style: GoogleFonts.poppins(fontSize: 12.sp),
      decoration: InputDecoration(
        hintText: 'Tulis alasan cuti...',
        hintStyle: GoogleFonts.poppins(fontSize: 11.5.sp, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.all(12.r),
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
                  content: Text(message, style: TextStyle(fontSize: 12.sp)),
                  backgroundColor: AppColors.green),
            );
            provider.resetForm();
            Navigator.pop(context);
          },
          error: (errorMessage) {
            setState(() => _isLoadingSubmit = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(errorMessage, style: TextStyle(fontSize: 12.sp)),
                  backgroundColor: AppColors.red),
            );
          },
          orElse: () => setState(() => _isLoadingSubmit = false),
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
                : () => _submitLeaveRequest(provider),
            child: _isLoadingSubmit
                ? SizedBox(
                    height: 18.r,
                    width: 18.r,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Ajukan Permohonan Cuti',
                    style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
          ),
        );
      },
    );
  }
}
