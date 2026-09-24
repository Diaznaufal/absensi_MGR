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
    // 🌟 1. Casting Total Days
    final int rawTotalDays = map['total_days'] is int
        ? map['total_days']
        : int.tryParse(map['total_days']?.toString() ?? '1') ?? 1;

    // 🌟 2. Type Handling
    int rawType = 1;
    if (map['type'] != null) {
      rawType = map['type'] is int
          ? map['type']
          : int.tryParse(map['type'].toString()) ?? 1;
    } else {
      rawType = rawTotalDays == 1 ? 1 : 2;
    }

    // 🌟 3. Ekstrak Jenis Cuti dari deskripsi jika leave_type kosong
    String rawDesc = map['description']?.toString() ?? '';
    String extractedLeaveType = map['leave_type']?.toString() ?? '';
    if (extractedLeaveType.isEmpty &&
        rawDesc.startsWith('[') &&
        rawDesc.contains(']')) {
      extractedLeaveType = rawDesc.substring(1, rawDesc.indexOf(']')).trim();
    }
    if (extractedLeaveType.isEmpty) {
      extractedLeaveType = 'Cuti Karyawan';
    }

    // 🌟 4. Parsing Tanggal Mulai (Prioritas: start_day, start_date, baru input_at)
    final dynamic rawStart =
        map['start_day'] ?? map['start_date'] ?? map['input_at'];
    DateTime parsedStartDate;
    if (rawStart != null &&
        rawStart.toString().trim().isNotEmpty &&
        rawStart != '0000-00-00') {
      parsedStartDate =
          DateTime.tryParse(rawStart.toString()) ?? DateTime.now();
    } else {
      parsedStartDate = DateTime.now();
    }

    // 🌟 5. Parsing Tanggal Selesai (Prioritas: end_day, end_date)
    final dynamic rawEnd = map['end_day'] ?? map['end_date'];
    DateTime? parsedEndDate;
    if (rawEnd != null &&
        rawEnd.toString().trim().isNotEmpty &&
        rawEnd != '0000-00-00') {
      parsedEndDate = DateTime.tryParse(rawEnd.toString());
    }

    return LeaveModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      status: map['status']?.toString() ?? 'pending',
      inputAt: (map['input_at'] != null && map['input_at'] != '0000-00-00')
          ? (DateTime.tryParse(map['input_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      type: rawType,
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      description: rawDesc,
      totalDays: rawTotalDays,
      approvedAt:
          (map['approved_at'] != null && map['approved_at'] != '0000-00-00')
              ? DateTime.tryParse(map['approved_at'].toString())
              : null,
      leaveType: extractedLeaveType,
      approver: map['approver']?.toString() ?? '-',
    );
  }
}
