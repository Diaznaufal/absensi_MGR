import 'package:flutter/material.dart';
import '../../../data/datasources/liburkaryawan_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/bloc/get_dayoff/get_dayoff_bloc.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/page/dayOff_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/response/liburkaryawan_response_model.dart';

class LiburkaryawanPage extends StatelessWidget {
  const LiburkaryawanPage({super.key});

  void _showActionModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (bottomSheetContext) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pilih Jenis Pengajuan',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildModalOption(
                    icon: Icons.beach_access,
                    iconColor: Colors.teal,
                    bgColor: Colors.teal.shade50,
                    title: "Hari Libur",
                    subtitle: "Ajukan hari libur anda",
                    onTap: () async {
                      // Tutup bottom sheet terlebih dahulu
                      Navigator.pop(bottomSheetContext);

                      // Menunggu feedback bernilai true saat FormDayOffPage sukses melakukan POST
                      final isUpdated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FormDayOffPage()));

                      // Jika sukses submit, trigger fetch ulang biar riwayat ter-update otomatis
                      if (isUpdated == true && context.mounted) {
                        context
                            .read<GetDayoffBloc>()
                            .add(const GetDayoffEvent.fetch());
                      }
                    }),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
  }

  Widget _buildModalOption(
      {required IconData icon,
      required Color iconColor,
      required Color bgColor,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey))
                ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Memicu fetch data secara otomatis saat page ini dimuat
      create: (context) => GetDayoffBloc(DayOffRemoteDatasource())
        ..add(const GetDayoffEvent.fetch()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 22),
              ),
              const SizedBox(width: 20),
              Text(
                'Libur Karyawan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: Builder(builder: (context) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Ajukan hari libur Anda',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                                'Kelola pengajuan jadwal kerja Anda dengan mudah.',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey))
                          ])),
                      const Icon(Icons.calendar_month,
                          size: 48, color: Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajukan'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A49B7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Riwayat Hari Libur',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Menggunakan BlocBuilder untuk merender list riwayat
                BlocBuilder<GetDayoffBloc, GetDayoffState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (message) => Center(child: Text(message)),
                      success: (responseModel) {
                        // Jika data list kosong
                        if (responseModel.data == null ||
                            responseModel.data!.isEmpty) {
                          return const Center(
                              child: Text('Belum ada riwayat pengajuan'));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: responseModel.data!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = responseModel.data![index];
                            return _buildHistoryCard(item);
                          },
                        );
                      },
                      orElse: () => const SizedBox(),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHistoryCard(DayOffData item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('Hari Libur',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(item.statusLabel ?? 'Pending',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
                child: Text('Tanggal Libur: ${item.tglDayOff ?? '-'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)))
          ]),
          const SizedBox(height: 8),
          Text(item.description ?? '-',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
