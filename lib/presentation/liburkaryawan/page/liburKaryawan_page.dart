import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/datasources/liburkaryawan_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/bloc/get_dayoff/get_dayoff_bloc.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/page/dayOff_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/response/liburkaryawan_response_model.dart';

class LiburkaryawanPage extends StatelessWidget {
  const LiburkaryawanPage({super.key});

  Color _getStatusBgColor(String? status) {
    switch (status) {
      case '1':
        return Colors.red.shade50;
      case '2':
        return Colors.green.shade50;
      case '3':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case '1':
        return Colors.red;
      case '2':
        return Colors.green;
      case '3':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showActionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Pilih Jenis Pengajuan',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildModalOption(
                icon: Icons.beach_access,
                iconColor: Colors.teal,
                bgColor: Colors.teal.shade50,
                title: "Hari Libur",
                subtitle: "Ajukan hari libur anda",
                onTap: () async {
                  Navigator.pop(bottomSheetContext);

                  final isUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormDayOffPage(),
                    ),
                  );

                  if (isUpdated == true && context.mounted) {
                    context
                        .read<GetDayoffBloc>()
                        .add(const GetDayoffEvent.fetch());
                  }
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.r),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20.r),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetDayoffBloc(DayOffRemoteDatasource())
        ..add(const GetDayoffEvent.fetch()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          toolbarHeight: 56.h,
          title: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 14.w),
              Text(
                'Libur Karyawan',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0A49B7),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Builder(
              builder: (context) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Info Atas (Gaya Modern Clean)
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ajukan hari libur Anda',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Kelola pengajuan jadwal kerja Anda dengan mudah.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A49B7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                size: 30.r,
                                color: const Color(0xFF0A49B7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _showActionModal(context),
                          icon: Icon(Icons.add_rounded, size: 18.r),
                          label: Text(
                            'Ajukan',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A49B7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Riwayat Hari Libur',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      BlocBuilder<GetDayoffBloc, GetDayoffState>(
                        builder: (context, state) {
                          return state.maybeWhen(
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0A49B7),
                                ),
                              ),
                            ),
                            error: (message) => Center(
                              child: Text(
                                message,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            success: (responseModel) {
                              if (responseModel.data == null ||
                                  responseModel.data!.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 24.h),
                                    child: Text(
                                      'Belum ada riwayat pengajuan',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: responseModel.data!.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 10.h),
                                itemBuilder: (context, index) {
                                  final item = responseModel.data![index];
                                  return _buildHistoryCard(item);
                                },
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(DayOffData item) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  'Hari Libur',
                  style: TextStyle(
                    color: Colors.teal.shade800,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(item.status),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: _getStatusTextColor(item.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  item.statusLabel ?? 'Pending',
                  style: TextStyle(
                    color: _getStatusTextColor(item.status),
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13.r,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Tanggal Libur: ${item.tglDayOff ?? '-'}',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            item.description ?? '-',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12.5.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
