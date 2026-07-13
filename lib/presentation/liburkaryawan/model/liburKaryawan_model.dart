class LiburkaryawanModel {
  final String id;
  final String nama;
  final String role;
  final String avatarUrl;
  final DateTime date;
  final String shiftName;
  final String timeRange;

  LiburkaryawanModel({
    required this.id,
    required this.nama,
    required this.role,
    required this.avatarUrl,
    required this.date,
    required this.shiftName,
    required this.timeRange,
  });
}

class submitLiburKaryawan {
  final String id;
  final String type;
  final String date;
  final String status;
  final String note;
  final String? peerName;

  submitLiburKaryawan({
    required this.id,
    required this.type,
    required this.date,
    required this.status,
    required this.note,
    this.peerName,
  });
}
