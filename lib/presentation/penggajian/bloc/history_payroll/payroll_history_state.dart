import '../../../../data/models/response/payroll_response_model.dart';

abstract class PayrollHistoryState {}

class PayrollHistoryInitial extends PayrollHistoryState {}

class PayrollHistoryLoading extends PayrollHistoryState {}

// State ketika berhasil memuat daftar riwayat per tahun
class PayrollHistoryLoaded extends PayrollHistoryState {
  final List<PayrollHistoryItem> history;
  final int year;
  PayrollHistoryLoaded(this.history, this.year);
}

// State ketika berhasil memuat rincian detail slip gaji tertentu
class PayrollDetailLoaded extends PayrollHistoryState {
  final PayrollData detail;
  PayrollDetailLoaded(this.detail);
}

class PayrollHistoryError extends PayrollHistoryState {
  final String message;
  PayrollHistoryError(this.message);
}
