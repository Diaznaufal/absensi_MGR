import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_absensi_app/presentation/history/pages/detail_history_page.dart';
import 'package:flutter_absensi_app/presentation/history/widgets/riwayat_absensi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../pages/schadule_kerja.dart';

import '../../../core/core.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedDate = DateTime.now();

  final _datasource = AttendanceRemoteDatasource();

  // Fungsi helper teks motivasi dinamis mengikuti persentase
  String getMotivationText(double percentageValue) {
    int percent = (percentageValue * 100).toInt();
    if (percent >= 0 && percent <= 20) {
      return "Ayo mulai langkahmu! Jangan malas untuk check-in ya 🚀";
    } else if (percent > 20 && percent <= 40) {
      return "Semangat! Tingkatkan lagi kehadiranmu minggu ini 🔥";
    } else if (percent > 40 && percent <= 60) {
      return "Cukup baik! Kamu sudah setengah jalan, yuk bisa yuk 👍";
    } else if (percent > 60 && percent <= 80) {
      return "Luar biasa! Pertahankan ritme kerjamu jangan sampai kendor ⚡";
    } else if (percent > 80 && percent < 95) {
      return "Sedikit lagi! Pertahankan konsistensimu 💪";
    } else if (percent >= 95 && percent <= 100) {
      return "Mantap! Target kehadiranmu tercapai, kamu hebat! 🎯🏆";
    }
    return "Tetap semangat bekerja dan jaga kesehatanmu! ✨";
  }

  Future<AttendanceResponseModel> fetchAttendanceHistory() async {
    // Menggunakan variabel state _selectedDate agar dinamis mengikuti filter picker
    final String bulan = _selectedDate.month.toString().padLeft(2, '0');
    final String tahun = _selectedDate.year.toString();

    final result =
        await _datasource.getScheduleByMonth(month: bulan, year: tahun);

    return result.fold(
        (errorMessage) => throw errorMessage, (responseModel) => responseModel);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF0A49B7),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xBAE7E8EC)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildAttendanceList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A49B7)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  Widget _buildAttendanceList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<AttendanceResponseModel>(
        future: fetchAttendanceHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan : ${snapshot.error}"));
          }

          if (!snapshot.hasData ||
              snapshot.data!.data == null ||
              snapshot.data!.data!.isEmpty) {
            return const Center(child: Text('Data History Kosong'));
          }

          final historiesAll = snapshot.data!.data!;
          final int bulanAktif = _selectedDate.month;
          final DateTime hariIni = DateTime.now();
          final DateTime tanggalSekarang =
              DateTime(hariIni.year, hariIni.month, hariIni.day);

          int countHadir = 0;
          int countTerlambat = 0;
          int countAbsen = 0;
          int countCuti = 0;
          int countDayOff = 0;
          int countMinggu = 0;
          int countLibur = 0;

          int totalHariValidKerjaSampaiHariIni = 0;
          int totalKerjaSatuBulanPenuh = 0;

          for (var item in historiesAll) {
            if (item.waktu != null && item.waktu!.month != bulanAktif) {
              continue;
            }

            final String label =
                item.statusLabel?.toString().toLowerCase() ?? "";
            final String currentStatuss = item.status?.toString() ?? "";

            // Lewati hari libur, minggu, atau tidak diketahui dari perhitungan hari kerja
            if (currentStatuss == '8' || label == 'Unknow') {
              countMinggu++;
              continue;
            }

            if (currentStatuss == '3' || label == 'Libur') {
              countLibur++;
              continue;
            }

            if (currentStatuss == '2' || label == 'Day Off') {
              countDayOff++;
              continue;
            }

            if (currentStatuss == '4' || label == 'Cuti') {
              countCuti++;
              continue;
            }

            // 1. Hitung total jadwal kerja aktif dalam 1 bulan penuh (untuk persentase atas)
            totalKerjaSatuBulanPenuh++;

            // Cek apakah tanggal item adalah hari esok/masa depan
            bool isMasaDepan = false;
            if (item.waktu != null) {
              final DateTime perbandinganTanggal = DateTime(
                  item.waktu!.year, item.waktu!.month, item.waktu!.day);
              if (perbandinganTanggal.isAfter(tanggalSekarang)) {
                isMasaDepan = true;
              }
            }

            // Jika hari esok, skip hitungan statistik tiga kotak di bawah
            if (isMasaDepan) {
              continue;
            }

            // 2. Hitung total hari kerja yang sudah berjalan sampai hari ini
            totalHariValidKerjaSampaiHariIni++;

            if (currentStatuss == "6" ||
                label == "sudah absen" ||
                label == "on time") {
              final bool isOntime = (item.timeManagement == 1 ||
                  item.timeManagement == true ||
                  item.timeManagement.toString() == "1");

              if (isOntime) {
                countHadir++;
              } else {
                countTerlambat++;
              }
            } else {
              // Terhitung absen jika hari sudah berjalan/lewat tapi status bukan 6
              countAbsen++;
            }
          }

          // Total presensi masuk (On Time + Terlambat)
          final int totalMasuk = countHadir + countTerlambat;

          // Rumus persentase berdasarkan seluruh total jadwal kerja 1 bulan penuh
          final double persentaseKehadiran = totalKerjaSatuBulanPenuh > 0
              ? (totalMasuk / totalKerjaSatuBulanPenuh)
              : 0.0;

          final int tahunAktif = _selectedDate.year;

          final bool isBulanSekarang =
              (hariIni.month == bulanAktif && hariIni.year == tahunAktif);
          List<dynamic> histories = [];

          if (isBulanSekarang) {
            // Hanya masukkan data dari awal bulan berjalan SAMPAI HARI INI SAJA
            final List<dynamic> saringanTanggalSekarang =
                historiesAll.where((item) {
              if (item.waktu == null) return false;
              try {
                final DateTime tanggalItem = DateTime(
                  item.waktu!.year,
                  item.waktu!.month,
                  item.waktu!.day,
                );
                return tanggalItem
                    .isBefore(tanggalSekarang.add(const Duration(days: 1)));
              } catch (_) {
                return false;
              }
            }).toList();
            histories = saringanTanggalSekarang.where((item) {
              final String label =
                  item.statusLabel?.toString().toLowerCase() ?? "";
              final String currentStatuss = item.status?.toString() ?? "";

              return !(currentStatuss == '3' ||
                  currentStatuss == '8' ||
                  label == 'Libur' ||
                  label == 'Minggu');
            }).toList();
            histories = histories.reversed.toList();
          } else {
            // Logika 1 minggu terakhir untuk bulan yang sudah terlewat
            final DateTime tanggalAkhirBulan =
                DateTime(tahunAktif, bulanAktif + 1, 0);
            final DateTime akhirPencarian = DateTime(tanggalAkhirBulan.year,
                tanggalAkhirBulan.month, tanggalAkhirBulan.day, 23, 59, 59);
            final DateTime awalPencarian = DateTime(tanggalAkhirBulan.year,
                    tanggalAkhirBulan.month, tanggalAkhirBulan.day)
                .subtract(const Duration(days: 6));

            final List<dynamic> saringanSatuMinggu = historiesAll.where((item) {
              if (item.waktu == null) return false;
              try {
                final DateTime tanggalItem =
                    DateTime.parse(item.waktu.toString());
                return tanggalItem.isAfter(
                        awalPencarian.subtract(const Duration(seconds: 1))) &&
                    tanggalItem.isBefore(
                        akhirPencarian.add(const Duration(seconds: 1)));
              } catch (_) {
                return false;
              }
            }).toList();

            histories = saringanSatuMinggu.where((item) {
              final String label =
                  item.statusLabel?.toString().toLowerCase() ?? "";
              final String currentStatuss = item.status?.toString() ?? "";

              return !(currentStatuss == "3" ||
                  currentStatuss == "8" ||
                  label == "libur" ||
                  label == "unknown" ||
                  label == "minggu" ||
                  label == "tanggal merah");
            }).toList();

            histories = histories.reversed.toList();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 1. Menggunakan totalKerjaSatuBulanPenuh untuk card persentase atas
                _buildPresencePercentageCard(
                    totalMasuk, totalKerjaSatuBulanPenuh, persentaseKehadiran),
                const SizedBox(height: 14),
                // 2. Menggunakan totalHariValidKerjaSampaiHariIni untuk card statistik bawah
                _buildStatisticCard(countHadir, countAbsen, countTerlambat,
                    totalHariValidKerjaSampaiHariIni),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Absensi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF253B80),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScheduleKerjaPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(10, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerRight,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent,
                      ),
                      child: Text(
                        'Lihat Semua',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4263F5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (histories.isEmpty)
                  const Expanded(
                    child: Center(
                      child:
                          Text('Belum ada riwayat absensi untuk periode ini.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: histories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      itemBuilder: (_, index) {
                        final item = histories[index];
                        final String backupTanggal = item.waktu != null
                            ? "${item.waktu!.year}-${item.waktu!.month.toString().padLeft(2, '0')}-${item.waktu!.day.toString().padLeft(2, '0')}"
                            : '';

                        return AttendanceHistoryCard(
                          day: item.tanggalMasuk ?? backupTanggal,
                          date: item.tanggalMasuk ?? backupTanggal,
                          checkIn: item.jamMasuk ?? '-',
                          checkOut: item.jamKeluar ?? '-',
                          status: () {
                            final String currentStatus =
                                item.status?.toString() ?? "";
                            final String label =
                                item.statusLabel?.toString().toLowerCase() ??
                                    "";

                            // 1. Validasi Record Absen Hadir (Status 6)
                            if (currentStatus == "6" ||
                                label == "sudah absen" ||
                                label == "on time") {
                              if (item.timeManagement == 1 ||
                                  item.timeManagement == true ||
                                  item.timeManagement.toString() == "1") {
                                return AttendanceStatus.onTime;
                              } else {
                                return AttendanceStatus.late;
                              }
                            }

                            // 2. Validasi Hari Minggu (Status 8)
                            if (currentStatus == "8" || label == "Unknown") {
                              return AttendanceStatus.minggu;
                            }

                            // 3. Validasi Tanggal Merah / Libur Nasional (Status 3)
                            if (currentStatus == "3" || label == "Libur") {
                              return AttendanceStatus.libur;
                            }

                            // 4. Validasi Day Off (Status 2)
                            if (currentStatus == "2" || label == "day off") {
                              return AttendanceStatus.dayoff;
                            }

                            // 5. Validasi Cuti / Izin
                            if (currentStatus == "4" || label == "Cuti") {
                              return AttendanceStatus.cuti;
                            }

                            // 6. Jika tidak masuk semua kondisi di atas, barulah Mangkir (Absen)
                            return AttendanceStatus.absent;
                          }(),
                          lateMinutes: () {
                            if (item.jamMasuk != null &&
                                item.clockIn != null &&
                                item.jamMasuk!.isNotEmpty &&
                                item.clockIn!.isNotEmpty) {
                              try {
                                final tahun = item.waktu!.year;
                                final bulan = item.waktu!.month;
                                final hari = item.waktu!.day;

                                final splitJamMasuk = item.jamMasuk!.split(':');
                                final splitClockIn = item.clockIn!.split(':');

                                final waktuCheckIn = DateTime(
                                    tahun,
                                    bulan,
                                    hari,
                                    int.parse(splitJamMasuk[0]),
                                    int.parse(splitJamMasuk[1]));
                                final waktuJadwalIn = DateTime(
                                    tahun,
                                    bulan,
                                    hari,
                                    int.parse(splitClockIn[0]),
                                    int.parse(splitClockIn[1]));
                                final selisihMenit = waktuCheckIn
                                    .difference(waktuJadwalIn)
                                    .inMinutes;

                                return selisihMenit > 0 ? selisihMenit : 0;
                              } catch (e) {
                                return 0;
                              }
                            }
                            return 0;
                          }(),
                          ontap: () {
                            print('ID Attendance: ${item.idAttendance}');
                            final String currentStatus =
                                item.status?.toString() ?? "";
                            final String label =
                                item.statusLabel?.toString().toLowerCase() ??
                                    "";

                            final bool isHolidayOrLeave =
                                currentStatus == "3" ||
                                    label == "Libur" ||
                                    currentStatus == "2" ||
                                    label == "Day Fff" ||
                                    currentStatus == "8" ||
                                    label == "Unknown" ||
                                    currentStatus == "4" ||
                                    label == "Cuti";

                            final bool hasNoAttendance =
                                item.idAttendance == null ||
                                    item.idAttendance!.isEmpty ||
                                    item.idAttendance == '-';

                            if (isHolidayOrLeave || hasNoAttendance) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Detail absensi tidak tersedia atau Anda belum melakukan check-in.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return; // Stop di sini, tidak masuk ke DetailHistoryPage
                            }

                            // 5. Jika lolos validasi, baru navigasi
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailHistoryPage(
                                  attendanceItem: item,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresencePercentageCard(int masuk, int total, double percent) {
    return _buildMainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Persentase kehadiran (Bulanan)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF253B80),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CirclePercent(progress: percent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$masuk dari $total hari kerja',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A3C7A),
                      ),
                    ),
                    Text(
                      'Target mingguan 95%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7A86A8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE6EAF4),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF4263F5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getMotivationText(percent),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF939DB8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(
      int hadir, int absen, int terlambat, int totalWorkingDays) {
    final hadirPercent =
        totalWorkingDays > 0 ? ((hadir / totalWorkingDays) * 100).round() : 0;
    final absenPercent =
        totalWorkingDays > 0 ? ((absen / totalWorkingDays) * 100).round() : 0;
    final terlambatPercent = totalWorkingDays > 0
        ? ((terlambat / totalWorkingDays) * 100).round()
        : 0;

    return _buildMainCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik kehadiran',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF253B80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: 'Tepat Waktu',
                  value: hadir.toString(),
                  subtitle: '$hadirPercent%',
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF19AF64),
                  bgColor: const Color(0xFFEAF8F0),
                  subtitleColor: const Color(0xFF1BAA62),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatItem(
                  title: 'Tidak Hadir',
                  value: absen.toString(),
                  subtitle: '$absenPercent%',
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFFF476C),
                  bgColor: const Color(0xFFFFEFF2),
                  subtitleColor: const Color(0xFFFF476C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatItem(
                  title: 'Terlambat',
                  value: terlambat.toString(),
                  subtitle: '$terlambatPercent%',
                  icon: Icons.access_time_filled,
                  iconColor: const Color(0xFFF5A300),
                  bgColor: const Color(0xFFFFF5E2),
                  subtitleColor: const Color(0xFFF5A300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EDF7)),
      ),
      child: child,
    );
  }
}

class _CirclePercent extends StatelessWidget {
  final double progress;

  const _CirclePercent({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      height: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFE8ECF6),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4263F5)),
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243778),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color subtitleColor;

  const _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF243778),
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF98A1BC),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: subtitleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
