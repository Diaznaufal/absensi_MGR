import '../pages/widgets/riwayat_absensi.dart';

final histories = [
  (
    day: 'Senin',
    date: '2 Juni 2025',
    checkIn: '08:00',
    checkOut: '17:00',
    status: AttendanceStatus.present,
    note: '',
  ),
  (
    day: 'Selasa',
    date: '3 Juni 2025',
    checkIn: '08:15',
    checkOut: '17:00',
    status: AttendanceStatus.late,
    note: '15 menit',
  ),
  (
    day: 'Rabu',
    date: '4 Juni 2025',
    checkIn: '-',
    checkOut: '-',
    status: AttendanceStatus.absent,
    note: '',
  ),
  (
    day: 'Kamis',
    date: '5 Juni 2025',
    checkIn: '08:00',
    checkOut: '19:30',
    status: AttendanceStatus.overtime,
    note: '2 jam 30 menit',
  ),
  (
    day: 'Jumat',
    date: '6 Juni 2025',
    checkIn: '08:00',
    checkOut: '17:00',
    status: AttendanceStatus.present,
    note: '',
  ),
  (
    day: 'Sabtu',
    date: '7 Juni 2025',
    checkIn: '08:00',
    checkOut: '17:00',
    status: AttendanceStatus.present,
    note: '',
  ),
];
