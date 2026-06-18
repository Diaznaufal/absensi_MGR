import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleKerjaPage extends StatefulWidget {
  const ScheduleKerjaPage({super.key});

  @override
  State<ScheduleKerjaPage> createState() => _ScheduleKerjaPageState();
}

class _ScheduleKerjaPageState extends State<ScheduleKerjaPage> {
  // Menyimpan bulan/tahun yang sedang aktif dilihat oleh user
  DateTime _focusedDay = DateTime(2026, 6, 18);
  DateTime? _selectedDay;

  // Simulasi database status kehadiran berdasarkan tanggal (Format: YYYY-MM-DD)
  // Anda tinggal menyesuaikan isi map ini dari API atau database lokal Anda nanti.
  final Map<String, Map<String, dynamic>> _attendanceData = {
    '2026-06-01': {
      'status': 'Tanggal Merah',
      'color': Color(0xFFE51C23),
      'text': Colors.white
    },
    '2026-06-02': {
      'status': 'Hadir',
      'color': Color(0xFF009688),
      'text': Colors.white
    },
    '2026-06-03': {
      'status': 'Hadir',
      'color': Color(0xFF009688),
      'text': Colors.white
    },
    '2026-06-04': {
      'status': 'Hadir',
      'color': Color(0xFF009688),
      'text': Colors.white
    },
    '2026-06-05': {
      'status': 'Tidak Hadir',
      'color': Color(0xFFFF5722),
      'text': Colors.white
    },
    '2026-06-06': {
      'status': 'Hadir',
      'color': Color(0xFF009688),
      'text': Colors.white
    },
    // Shift jam kerja
    '2026-06-19': {
      'status': '08:00 -\n17:00',
      'color': Color(0xFFA5D6A7),
      'text': Color(0xFF2E7D32)
    },
    '2026-06-20': {
      'status': '08:00 -\n17:00',
      'color': Color(0xFFA5D6A7),
      'text': Color(0xFF2E7D32)
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule',
          style:
              TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

              // Mengatur tinggi baris kalender agar muat badge teks di bawah angka tanggal
              rowHeight: 70,

              // Pengaturan konfigurasi Header atas (Nama Bulan & Panah)
              headerStyle: const HeaderStyle(
                formatButtonVisible:
                    false, // Menyembunyikan tombol format 2 weeks / month
                titleCentered: true,
                titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.black),
              ),

              // Pengaturan teks nama-nama hari (Minggu - Sabtu)
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                weekendStyle: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),

              // Deteksi ketika user menekan tombol pindah bulan (panah kiri/kanan)
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },

              // FITUR UTAMA: Mengkustomisasi tampilan kotak tanggal di dalam kalender secara penuh
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) =>
                    _buildCell(day, false),
                outsideBuilder: (context, day, focusedDay) =>
                    const SizedBox.shrink(), // Sembunyikan tanggal bulan lain
                todayBuilder: (context, day, focusedDay) =>
                    _buildCell(day, true),
                holidayBuilder: (context, day, focusedDay) =>
                    _buildCell(day, false),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pembentuk satu kotak tanggal kalender secara dinamis
  Widget _buildCell(DateTime day, bool isToday) {
    // Format tanggal menjadi String key 'YYYY-MM-DD'
    String dateKey =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    bool isMinggu = day.weekday == DateTime.sunday;

    // Default badge hari Minggu jika tidak ada jadwal khusus di map database
    Map<String, dynamic>? customData = _attendanceData[dateKey];
    String statusText = customData != null
        ? customData['status']
        : (isMinggu ? 'Hari Minggu' : '');
    Color badgeColor = customData != null
        ? customData['color']
        : (isMinggu ? const Color(0xFFF3E5F5) : Colors.transparent);
    Color textColor = customData != null
        ? customData['text']
        : (isMinggu ? const Color(0xFF9C27B0) : Colors.black);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: isToday
          ? BoxDecoration(
              color: const Color(
                  0xFFE0E7FF), // Highlight biru lembut khusus untuk hari ini
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Angka Tanggal asli dari kalender sistem
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isMinggu && customData == null
                  ? const Color(0xFF9C27B0)
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // Teks badge status dinamis di bawah tanggal
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
