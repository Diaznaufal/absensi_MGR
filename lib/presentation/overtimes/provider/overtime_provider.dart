import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/overtime_model.dart';

class OvertimeProvider extends ChangeNotifier {
  String _currentStatus = 'not_started';
  String get currentStatus => _currentStatus;

  final List<OvertimeModel> _historyList = [];
  List<OvertimeModel> get historyList => _historyList;

  // FLOW A: INPUT MANUAL / AJUKAN RENCANA DI AWAL
  void addManualOvertime({
    required String date,
    required String startTime,
    required String endTime,
    required String reason,
    String? notes,
  }) {
    final newOvertime = OvertimeModel(
      id: DateTime.now().millisecondsSinceEpoch,
      date: date,
      startTime: startTime,
      endTime: endTime,
      status: 'pending',
      reason: reason,
      notes: notes,
      isManual: true,
    );

    _currentStatus = 'not_started';
    _historyList.insert(0, newOvertime);
    notifyListeners();
  }

  // FLOW B: VALIDASI REAL-TIME JADWAL YANG SUDAH ADA
  void startOvertime() {
    final now = DateTime.now();
    final formattedToday = DateFormat('yyyy-MM-dd').format(now);

    try {
      final todayOvertime = _historyList.firstWhere(
        (element) => element.date == formattedToday && element.status == 'pending',
      );

      todayOvertime.startTime = DateFormat('HH:mm').format(now);
      _currentStatus = 'in_progress';
      notifyListeners();
    } catch (e) {
      debugPrint("Sistem: Data jadwal tidak ditemukan.");
    }
  }

  // FLOW C: LANGSUNG CHECK IN KARENA URGENT (Daftar Instan Baru)
  void startUrgentOvertime({required String reason, String? notes}) {
    final now = DateTime.now();
    
    final urgentOvertime = OvertimeModel(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateFormat('yyyy-MM-dd').format(now),
      startTime: DateFormat('HH:mm').format(now), // Jam mulai otomatis detik ini
      endTime: '-', // Belum selesai
      status: 'pending',
      reason: '$reason',
      notes: notes,
      isManual: false, // Tercatat real-time dari tombol
    );

    _historyList.insert(0, urgentOvertime);
    _currentStatus = 'in_progress';
    notifyListeners();
  }

  // FLOW D: SELESAI LEMBUR (Bisa dari Terjadwal maupun Urgent)
  void endOvertime() {
    final now = DateTime.now();
    final formattedToday = DateFormat('yyyy-MM-dd').format(now);

    try {
      final todayOvertime = _historyList.firstWhere(
        (element) => element.date == formattedToday && element.status == 'pending',
      );

      todayOvertime.endTime = DateFormat('HH:mm').format(now);
      _currentStatus = 'completed';
      notifyListeners();
    } catch (e) {
      debugPrint("Sistem: Gagal Check Out.");
    }
  }

  void resetSimulasi() {
    _currentStatus = 'not_started';
    notifyListeners();
  }
}