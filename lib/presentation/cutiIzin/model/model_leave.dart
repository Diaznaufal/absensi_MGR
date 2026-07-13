class LeaveModel {
  final int id;
  final String status;
  final DateTime inputAt;
  final int type;
  final DateTime startDate;
  final DateTime? endDate;
  final String description;
  final int totalDays;
  final DateTime? approvedAt;
  final String leaveType;
  final String approver;

  LeaveModel({
    required this.id,
    required this.status,
    required this.inputAt,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.description,
    required this.totalDays,
    this.approvedAt,
    required this.leaveType,
    required this.approver,
  });
  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    // 🌟 AMANKAN CASTING TOTAL DAYS (Mengantisipasi jika API mengirim String)
    final int rawTotalDays = map['total_days'] is int
        ? map['total_days']
        : int.tryParse(map['total_days']?.toString() ?? '1') ?? 1;

    // Ambil nilai type dari API, jika null mari kita tebak otomatis dari total_days
    int rawType = 1;
    if (map['type'] != null) {
      rawType = map['type'] is int
          ? map['type']
          : int.tryParse(map['type'].toString()) ?? 1;
    } else {
      // Jika API GET tidak mengembalikan field 'type', kita kalkulasi dari total_days
      rawType = rawTotalDays == 1 ? 1 : 2;
    }
    String extractedLeaveType = '';
    return LeaveModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      status: map['status']?.toString() ?? 'pending',
      inputAt: map['input_at'] != null
          ? DateTime.parse(map['input_at'].toString())
          : DateTime.now(),
      type: rawType,
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'].toString())
          : DateTime.now(),
      // 🌟 Amankan parsing endDate jika berupa string kosong atau "0000-00-00"
      endDate: (map['end_date'] != null &&
              map['end_date'].toString().trim().isNotEmpty &&
              map['end_date'] != '0000-00-00')
          ? DateTime.parse(map['end_date'].toString())
          : null,
      description: map['description']?.toString() ?? '',
      totalDays: rawTotalDays, // 🌟 Masukkan hasil casting aman ke properti
      approvedAt:
          map['approved_at'] != null && map['approved_at'] != '0000-00-00'
              ? DateTime.parse(map['approved_at'].toString())
              : null,
      leaveType: extractedLeaveType,
      approver: map['approver']?.toString() ?? '-',
    );
  }
}
