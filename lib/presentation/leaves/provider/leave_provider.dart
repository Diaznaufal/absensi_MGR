import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../model/model_leave.dart';

class LeaveProvider with ChangeNotifier {
  LeaveProvider() {
    reasonController.addListener(notifyListeners);
  }

  // --- State Data Riwayat ---
  final List<LeaveModel> _listLeave = [];
  List<LeaveModel> get listLeave => [..._listLeave];

  // Tipe cuti statis bawaan aplikasi
  final List<String> leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Emergency Leave',
    'Unpaid Leave',
  ];

  // --- State Formulir Pengajuan (Form-State) ---
  String? _selectedLeaveType = 'Annual Leave'; // Default awal
  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;
  String? _selectedFileName;

  final TextEditingController reasonController = TextEditingController();

  // Getters untuk Form
  String? get selectedLeaveType => _selectedLeaveType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  File? get selectedFile => _selectedFile;
  String? get selectedFileName => _selectedFileName;

  // Setters untuk Form
  void setSelectedLeaveType(String type) {
    _selectedLeaveType = type;
    notifyListeners();
  }

  void setDates(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setAttachment(String path, String name) {
    _selectedFile = File(path);
    _selectedFileName = name;
    notifyListeners();
  }

  // --- Logika File Picker ---
  Future<void> pickAttachment(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );

    if (result != null && result.files.single.path != null) {
      PlatformFile file = result.files.single;

      // Batasan ukuran 4MB seperti Pengaduan
      const int maxSizeBytes = 4 * 1024 * 1024;
      if (file.size > maxSizeBytes) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal! Ukuran file melebihi 4 MB."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _selectedFile = File(file.path!);
      _selectedFileName = file.name;
      notifyListeners();
    }
  }

  void removeAttachment() {
    _selectedFile = null;
    _selectedFileName = null;
    notifyListeners();
  }

  // --- Validasi & Submit ---
  bool isFormValid() {
    if (_selectedLeaveType == null) return false;
    if (_startDate == null) return false;
    if (_endDate == null) return false;
    if (reasonController.text.trim().isEmpty) return false;
    if (_endDate!.isBefore(_startDate!)) return false;
    return true;
  }

  void tambahCuti() {
    if (!isFormValid()) return;

    final int totalDays = _endDate!.difference(_startDate!).inDays + 1;

    final newLeave = LeaveModel(
      id: _listLeave.length + 1,
      status: 'pending',
      startDate: _startDate!,
      endDate: _endDate!,
      reason: reasonController.text.trim(),
      totalDays: totalDays,
      attachmentPath: _selectedFile?.path,
      leaveType: _selectedLeaveType!,
      approver: 'Awaiting assignment',
    );

    _listLeave.insert(0, newLeave);
    resetForm();
  }

  void resetForm() {
    _selectedLeaveType = leaveTypes.isNotEmpty ? leaveTypes.first : null;
    _startDate = null;
    _endDate = null;
    _selectedFile = null;
    _selectedFileName = null;
    reasonController.clear();
    notifyListeners();
  }

  // --- UI Helper Terpusat untuk Icon Dinamis ---
  IconData getLeaveIcon(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('annual') || lowerName.contains('tahunan')) {
      return Icons.beach_access_rounded;
    } else if (lowerName.contains('sick') || lowerName.contains('sakit')) {
      return Icons.local_hospital_rounded;
    } else if (lowerName.contains('emergency') ||
        lowerName.contains('darurat')) {
      return Icons.emergency_rounded;
    } else if (lowerName.contains('unpaid')) {
      return Icons.money_off_rounded;
    }
    return Icons.event_note_rounded;
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
