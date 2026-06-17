class OvertimeModel {
  final int? id;
  final String? date;      // Format: yyyy-MM-DD
  String? startTime;       // Format: HH:mm
  String? endTime;         // Format: HH:mm
  String? status;          // 'approved', 'rejected', 'pending'
  final String? reason;
  final String? notes;
  final String? documentPath;
  final DateTime? approvedAt;
  final bool isManual;     // Menandakan input susulan/manual

  OvertimeModel({
    this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.status = 'pending',
    this.reason,
    this.notes,
    this.documentPath,
    this.approvedAt,
    this.isManual = false,
  });
}