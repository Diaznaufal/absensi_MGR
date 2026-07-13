class ModelIzin {
  final int id;
  final int idEmployee;
  final String status; // Berisi '0', '1', atau '2' dari BE
  final DateTime inputAt;
  final DateTime tanggalIzin;
  final DateTime? endDate;
  final int typeDay;
  final String alasanIzin;
  final String description;
  final String? buktiSuratSakit;

  ModelIzin({
    required this.id,
    required this.idEmployee,
    required this.status,
    required this.inputAt,
    required this.tanggalIzin,
    this.endDate,
    required this.typeDay,
    required this.alasanIzin,
    required this.description,
    this.buktiSuratSakit,
  });

  // 🌟 LOGIKA UI 1: Get teks status approval secara lokal berdasarkan data status BE
  String get statusLabel {
    switch (status) {
      case '1':
        return 'Ditolak';
      case '2':
        return 'Disetujui';
      case '0':
      default:
        return 'Pending';
    }
  }

  // 🌟 LOGIKA UI 2: Hitung total hari murni untuk UI (tidak dikirim ke BE)
  int get calculatedTotalDays {
    if (typeDay == 1 || endDate == null) {
      return 1; // Jika Single Day, otomatis 1 hari
    }
    // Jika Multi Day, hitung selisih tanggal_izin sampai end_date
    final startOnly = DateTime(tanggalIzin.year, tanggalIzin.month, tanggalIzin.day);
    final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
    
    return endOnly.difference(startOnly).inDays + 1; // +1 agar hari pertama terhitung
  }

  factory ModelIzin.fromMap(Map<String, dynamic> map) {
    return ModelIzin(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      idEmployee: map['id_employee'] is int
          ? map['id_employee']
          : int.tryParse(map['id_employee']?.toString() ?? '0') ?? 0,
      status: map['status']?.toString() ?? '0',
      inputAt: map['input_at'] != null
          ? DateTime.parse(map['input_at'].toString())
          : DateTime.now(),
      tanggalIzin: map['tanggal_izin'] != null
          ? DateTime.parse(map['tanggal_izin'].toString())
          : DateTime.now(),
      endDate: (map['end_date'] != null &&
              map['end_date'].toString().trim().isNotEmpty &&
              map['end_date'] != '0000-00-00')
          ? DateTime.parse(map['end_date'].toString())
          : null,
      typeDay: map['type_day'] is int
          ? map['type_day']
          : int.tryParse(map['type_day']?.toString() ?? '1') ?? 1,
      alasanIzin: map['alasan_izin'] ?? '',
      description: map['description'] ?? '',
      buktiSuratSakit: map['bukti_surat_sakit'] ?? '-',
    );
  }
}