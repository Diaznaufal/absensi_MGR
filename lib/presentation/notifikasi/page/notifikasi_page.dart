import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_absensi_app/presentation/notifikasi/model/notifikasi_model.dart';
import 'package:flutter_absensi_app/presentation/notifikasi/widget/notifikasi_card.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});
  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final List<NotifikasiModel> _notifList = [
    NotifikasiModel(
      id: '1',
      icon: Icons.event_busy_rounded,
      color: Colors.red,
      iconBg: const Color(0xFFFFE5EA),
      title: 'Cuti Disetuji',
      subtitle:
          'Pengajuan cuti tahunan anda pada tanggal 20-22 juni 2026 telah disetujui oleh HRD',
      time: DateTime.now(),
      isread: false,
    ),
    NotifikasiModel(
      id: '2',
      icon: Icons.wallet_giftcard_rounded,
      color: Colors.green,
      iconBg: const Color(0xFFDFF5E7),
      title: 'Gaji Telah Dibayarkan',
      subtitle:
          'Informasi gaji juni 2026 sudah dibayarkan. Silahkan cek detailnya melalui menu penggajian',
      time: DateTime.now(),
      isread: true,
    ),
    NotifikasiModel(
      id: '3',
      icon: Icons.schedule_rounded,
      color: const Color(0xFF0059FF),
      iconBg: const Color(0xFFDCE7FF),
      title: 'Lembur Disetuji',
      subtitle:
          'Pengajuan lembur anda pada tanggal 17 juni 2026 telah disetujui oleh admin',
      time: DateTime.now(),
      isread: true,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A49B7),
        toolbarHeight: 56.h,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r)),
                child: Padding(
                  padding: EdgeInsets.only(right: 1.w),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18.r,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _notifList.clear();
                });
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r)),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            children: [
              Expanded(
                child: _notifList.isEmpty
                    ? Center(
                        child: Text(
                          'No Notifikasi',
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifList.length,
                        itemBuilder: (context, index) {
                          final item = _notifList[index];

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 4.h),
                            child: Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  setState(() {
                                    _notifList
                                        .removeWhere((e) => e.id == item.id);
                                  });
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 14.w),
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      item.isread = true;
                                    });
                                  },
                                  child: NotifikasiCard(notif: item),
                                )),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
