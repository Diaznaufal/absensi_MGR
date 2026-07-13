import 'package:flutter/material.dart';
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
      iconBg: Color(0xFFFFE5EA),
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
      iconBg: Color(0xFFDFF5E7),
      title: 'Gaji Telah Dibayarkan',
      subtitle:
          'Informasi gaji juni 2026 sudah dibayarkan. Silahkan cek detailnya melalui menu penggajian',
      time: DateTime.now(),
      isread: true,
    ),
    NotifikasiModel(
      id: '3',
      icon: Icons.schedule_rounded,
      color: Color(0xFF0059FF),
      iconBg: Color(0xFFDCE7FF),
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
        backgroundColor: Color(0xFF0A49B7),
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 22,
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
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Expanded(
              // 1. Ubah isNotEmpty menjadi isEmpty agar logikanya benar
              child: _notifList.isEmpty
                  ? Center(
                      child: Text(
                        'No Notifikasi',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          _notifList.length, // 2. Tambahkan itemCount di sini
                      itemBuilder: (context, index) {
                        final item = _notifList[index];

                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          child: Dismissible(
                              key: ValueKey(
                                  item.id), // 3. Ubah Key menjadi item.id
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                setState(() {
                                  _notifList
                                      .removeWhere((e) => e.id == item.id);
                                });
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
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
      )),
    );
  }
}
