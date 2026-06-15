class LeaveModel {
  final int id;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final int totalDays;
  final String? attachmentPath;
  final DateTime? approvedAt;
  final String leaveType;
  final String approver;

  LeaveModel({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.totalDays,
    this.attachmentPath,
    this.approvedAt,
    required this.leaveType,
    required this.approver,
  });
}