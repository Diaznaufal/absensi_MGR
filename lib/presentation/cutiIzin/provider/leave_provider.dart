import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import '../model/model_leave.dart';

class LeaveProvider with ChangeNotifier {
  LeaveProvider() {
    reasonController.addListener(notifyListeners);
  }

  // --- State Data Riwayat ---
  List<LeaveModel> _listLeave = [];
  List<LeaveModel> get listLeave => _listLeave;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<String> leaveTypes = [
    'Cuti Tahunan',
    'Cuti Sakit',
  ];

  // --- State Formulir Pengajuan (Form-State) ---
  String? _selectedLeaveType = 'Cuti Tahunan';
  DateTime? _startDate;
  DateTime? _endDate;
  int _typeDay = 1;
  int _totalDays = 1;

  final TextEditingController reasonController = TextEditingController();

  String? get selectedLeaveType => _selectedLeaveType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get typeDay => _typeDay;
  int get totalDays => _totalDays;

  void setSelectedLeaveType(String type) {
    _selectedLeaveType = type;
    notifyListeners();
  }

  void setTypeDay(int type) {
    _typeDay = type;
    if (_typeDay == 1) {
      _endDate == _startDate;
      _totalDays = 1;
    } else {
      _endDate == null;
      _totalDays = 0;
    }
    notifyListeners();
  }

  void setDates(DateTime? start, DateTime? end) {
    _startDate = start;
    if (_typeDay == 1) {
      _endDate = start;
      _totalDays = 1;
    } else {
      _endDate = end;
      if (_startDate != null && _endDate != null) {
        DateTime startOnly =
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        DateTime endOnly =
            DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        _totalDays = endOnly.difference(startOnly).inDays + 1;
      } else {
        _totalDays = 0;
      }
    }
    notifyListeners();
  }

  // --- Ambil Data Riwayat Murni Cuti ---
  Future<void> getLeaveHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await LeaveRemoteDatasource().getLeave();

      result.fold(
        (l) => debugPrint("Gagal mengambil data cuti: $l"),
        (r) {
          _listLeave = r
              .map((item) => LeaveModel.fromMap(item as Map<String, dynamic>))
              .toList();

          // Urutkan berdasarkan ID terbesar
          _listLeave.sort((a, b) => b.id.compareTo(a.id));
        },
      );
    } catch (e) {
      debugPrint("Gagal memproses riwayat cuti: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Validasi & Submit ---
  bool isFormValid() {
    if (_selectedLeaveType == null) return false;
    if (_startDate == null) return false;
    if (reasonController.text.trim().isEmpty) return false;

    // Jika tipenya Multi Day (2), End Date wajib ada dan valid
    if (_typeDay == 2) {
      if (_endDate == null) return false;
      if (_endDate!.isBefore(_startDate!)) return false;
    }

    // Jika _typeDay == 1 (Single Day), ia langsung lolos ke sini tanpa mewajibkan _endDate lewat hari
    return true;
  }

  void resetForm() {
    _selectedLeaveType = leaveTypes.isNotEmpty ? leaveTypes.first : null;
    _startDate = null;
    _endDate = null;
    _typeDay = 1;
    _totalDays = 1;
    reasonController.clear();
    notifyListeners();
  }

  // --- UI Helper Terpusat untuk Icon Cuti Murni ---
  IconData getLeaveIcon(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('Cuti Tahunan')) return Icons.beach_access_rounded;
    if (lowerName.contains('Cuti Sakit')) return Icons.local_hospital_rounded;
    return Icons.event_note_rounded;
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
