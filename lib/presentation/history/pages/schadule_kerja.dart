import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/history/model/kalender_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduleKerjaPage extends StatefulWidget {
  const ScheduleKerjaPage({super.key});

  @override
  State<ScheduleKerjaPage> createState() => _ScheduleKerjaPageState();
}

class _ScheduleKerjaPageState extends State<ScheduleKerjaPage> {
  final AttendanceRemoteDatasource _datasource = AttendanceRemoteDatasource();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<kalenderModel> _schedule = [];
  bool _isLoading = false;

  // Map untuk mempermudah pencarian data kalender berdasarkan String key 'YYYY-MM-DD'
  Map<String, kalenderModel> get attendanceData => {
        for (final item in _schedule)
          "${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}":
              item,
      };

  @override
  void initState() {
    super.initState();
    _loadingAbsenceHistory();
  }

  Future<void> _loadingAbsenceHistory() async {
    setState(() => _isLoading = true);
    final result = await _datasource.getAbsenceAll();
    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      },
      (responseModel) {
        setState(() {
          final DateTime hariIni = DateTime.now();
          final DateTime tanggalSekarang =
              DateTime(hariIni.year, hariIni.month, hariIni.day);

          _schedule = responseModel.data!.map((item) {
            // Trim spasi kosong tak terlihat agar pengecekan string valid 100%
            final String currentStatus = item.status?.toString().trim() ?? "";
            final String label =
                item.statusLabel?.toString().toLowerCase().trim() ?? "";

            final DateTime itemDate = item.waktu ?? DateTime.now();
            final DateTime perbandinganTanggal =
                DateTime(itemDate.year, itemDate.month, itemDate.day);

            String formatJam(String? jam) {
              if (jam == null || jam.isEmpty) return "";
              final parts = jam.split(':');
              if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
              return jam;
            }

            String jamMasuk = formatJam(item.clockIn);
            String jamKeluar = formatJam(item.clockOut);

            // Format jam kerja default dinamis langsung mengikuti manifes BE
            String customJamKerja =
                (jamMasuk.isNotEmpty && jamKeluar.isNotEmpty)
                    ? "$jamMasuk -\n$jamKeluar"
                    : "08:00 -\n17:00";

            statusKalender status = statusKalender.tidakHadir;
            String titleText = '';

            if (currentStatus == '8' || label == 'Unknown') {
              status = statusKalender.minggu;
            } else if (currentStatus == '3' || label == 'Libur') {
              status = statusKalender.holiday;
            } else if (label == 'Day Off' || currentStatus == '2') {
              status = statusKalender.dayOff;
            } else if (label == 'Cuti' || currentStatus == '4') {
              status = statusKalender.cuti;
            }
            //=======
            else if (currentStatus == "6" ||
                label == "sudah absen" ||
                label == "on time") {
              final bool isOntime = (item.timeManagement == 1 ||
                  item.timeManagement == true ||
                  item.timeManagement.toString() == "1");

              if (isOntime) {
                status = statusKalender.ontime;
              } else {
                status = statusKalender.terlambat;
              }
            } else {
              if (perbandinganTanggal.isAfter(tanggalSekarang) ||
                  perbandinganTanggal.isAtSameMomentAs(tanggalSekarang)) {
                // Hari ini atau esok yang belum diabsen: set status ontime agar dasar warnanya hijau,
                // tapi variabel titleText diisi jam kerja dari BE agar di UI dicetak string jamnya.
                status = statusKalender.ontime;
                titleText = customJamKerja;
              } else {
                // Hari kerja kemarin yang sudah lewat tanpa scan absensi masuk
                status = statusKalender.tidakHadir;
              }
            }

            return kalenderModel(
              date: itemDate,
              status: status,
              title: titleText,
            );
          }).toList();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Kalender Kehadiran',
            style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A49B7),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        rowHeight: 70,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A)),
                          leftChevronIcon:
                              Icon(Icons.chevron_left, color: Colors.black),
                          rightChevronIcon:
                              Icon(Icons.chevron_right, color: Colors.black),
                        ),
                        weekendDays: [DateTime.sunday],
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                          weekendStyle: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) =>
                              _buildCell(day, false),
                          outsideBuilder: (context, day, focusedDay) =>
                              const SizedBox.shrink(),
                          todayBuilder: (context, day, focusedDay) =>
                              _buildCell(day, true),
                          holidayBuilder: (context, day, focusedDay) =>
                              _buildCell(day, false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCell(DateTime day, bool isToday) {
    String dateKey =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    String getStatusText(statusKalender status) {
      switch (status) {
        case statusKalender.ontime:
          return 'On\nTime';
        case statusKalender.terlambat:
          return 'Ter\nlambat';
        case statusKalender.tidakHadir:
          return 'Tidak\nHadir';
        case statusKalender.minggu:
          return 'Hari\nMinggu';
        case statusKalender.holiday:
          return 'Tanggal\nMerah';
        case statusKalender.dayOff:
          return 'Hari\nLibur';
        case statusKalender.cuti:
          return 'Cuti\nKerja';
      }
    }

    Color getBadgeColor(statusKalender status) {
      switch (status) {
        case statusKalender.ontime:
          return const Color(0xFF009688);
        case statusKalender.terlambat:
          return Colors.amberAccent;
        case statusKalender.tidakHadir:
          return const Color(0xFFFF5722);
        case statusKalender.minggu:
          return const Color(0xFFF3E5F5);
        case statusKalender.holiday:
        case statusKalender.dayOff:
        case statusKalender.cuti:
          return const Color(0xFFE51C23);
      }
    }

    Color getTextColor(statusKalender status) {
      switch (status) {
        case statusKalender.minggu:
          return const Color(0xFF9C27B0);
        case statusKalender.terlambat:
          return Colors.black;
        default:
          return Colors.white;
      }
    }

    kalenderModel? customData = attendanceData[dateKey];
    String statusText;
    Color badgeColor;
    Color textColor;

    if (customData != null) {
      // Jika model membawa data judul jam kerja (Layer 3), tampilkan teks jam tersebut
      if (customData.title.isNotEmpty) {
        statusText = customData.title;
        badgeColor = const Color(0xffa5d6a7); // Hijau lembut jadwal aktif
        textColor = const Color(0xff2e7d32);
      } else {
        // Jika tidak ada teks jam kerja, render status konkrit ("On Time", "Terlambat", "Tanggal Merah")
        statusText = getStatusText(customData.status);
        badgeColor = getBadgeColor(customData.status);
        textColor = getTextColor(customData.status);
      }
    } else {
      // JIKA DATA DARI BE SAMA SEKALI TIDAK ADA (Contoh: Bulan Agustus)
      // Dibuat kosong bersih murni mengikuti BE tanpa manipulasi kosmetik lokal
      statusText = '';
      badgeColor = Colors.transparent;
      textColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: isToday
          ? BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color:
                  //  (customData != null &&
                  //             customData.status == statusKalender.minggu) ||
                  //         (customData == null && isMinggu)
                  //     ? const Color(
                  //         0xFF9C27B0) // Teks angka ungu murni jika terbukti hari minggu
                  //     :
                  Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (statusText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
