import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/overtime_model.dart';

class OvertimeProvider extends ChangeNotifier {
  String _currentStatus = 'not_started';
  String get currentStatus => _currentStatus;

  // Menyimpan referensi lembur manual yang sedang divalidasi hari ini
  OvertimeModel? _activeOvertime;
  OvertimeModel? get activeOvertime => _activeOvertime;

  final List<OvertimeModel> _historyList = [];
  List<OvertimeModel> get historyList => _historyList;

  // ==========================================
  // FLOW A: INPUT MANUAL / AJUKAN DI AWAL
  // ==========================================
  void addManualOvertime({
    required String date,
    required String startTime,
    required String endTime,
    required String reason,
    String? notes,
  }) {
    // 1. Buat data pengajuan manual
    _activeOvertime = OvertimeModel(
      id: DateTime.now().millisecondsSinceEpoch,
      date: date,
      startTime: startTime, // Jam rencana awal
      endTime: endTime,     // Jam rencana akhir
      status: 'pending',
      reason: reason,
      notes: notes,
      isManual: true,
    );

    // 2. Karena ini lembur terencana/terjadwal, ubah status menjadi 'not_started' 
    // agar tombol "Check In" menyala dan siap divalidasi oleh karyawan saat jam kerja tiba.
    _currentStatus = 'not_started';
    
    // Masukkan ke history sebagai draf pending awal
    _historyList.insert(0, _activeOvertime!);
    notifyListeners();
  }

  // ==========================================
  // FLOW B: VALIDASI REAL-TIME (TOMBOL ABSEN)
  // ==========================================
  
  // Tombol Check In diklik untuk memvalidasi waktu mulai riil
  void startOvertime() {
    if (_activeOvertime != null) {
      final now = DateTime.now();
      // Validasi: Timpa jam mulai rencana dengan jam check in riil (optional, atau biarkan tetap)
      _activeOvertime!.startTime = DateFormat('HH:mm').format(now);
      
      _currentStatus = 'in_progress';
      notifyListeners();
    }
  }

  // Tombol Check Out diklik untuk memvalidasi waktu selesai riil
  void endOvertime() {
    if (_activeOvertime != null) {
      final now = DateTime.now();
      // Validasi: Timpa jam selesai rencana dengan jam check out riil
      _activeOvertime!.endTime = DateFormat('HH:mm').format(now);
      _activeOvertime!.status = 'pending'; // Dikunci untuk dikirim ke admin

      // Update data di list history (karena object-nya reference, otomatis ter-update)
      _currentStatus = 'completed';
      notifyListeners();
    }
  }

  void resetSimulasi() {
    _currentStatus = 'not_started';
    _activeOvertime = null;
    notifyListeners();
  }
}