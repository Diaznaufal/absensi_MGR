import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/datasources/izin_remote_datasource.dart';
import '../model/model_izin.dart';

class IzinProvider with ChangeNotifier {
  IzinProvider() {
    descriptionController.addListener(notifyListeners);
  }
  final TextEditingController descriptionController = TextEditingController();

  List<ModelIzin> _listIzin = [];
  List<ModelIzin> get listIzin => _listIzin;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _startDate;
  DateTime? _endDate;
  int _typeDay = 1;

  final List<String> alasanIzinOption = [
    'Izin Keluarga Melahirkan',
    'Izin Menghadiri Acara Keagamaan',
    'Izin Sakit',
    'Izin Mengurus Administrasi',
    'Izin Menghadiri Pemakaman',
    'Keperluan Mendesak Lainnya',
  ];

  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedAlasanIzin;

  File? get selectedFile => _selectedFile;
  String? get selectedFileName => _selectedFileName;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get typeDay => _typeDay;
  String? get selectedAlasanIzin => _selectedAlasanIzin;

  void setTypeDay(int type) {
    _typeDay = type;
    if (_typeDay == 1) {
      _endDate = _startDate;
    } else {
      _endDate = null;
    }
    notifyListeners();
  }

  void setSelectedAlasanIzin(String? value) {
    _selectedAlasanIzin = value;
    notifyListeners();
  }

  void setDates(DateTime? start, DateTime? end) {
    _startDate = start;
    if (_typeDay == 1) {
      _endDate = start;
    } else {
      _endDate = end;
    }
    notifyListeners();
  }

  void setAttachment(String path, String name) {
    _selectedFile = File(path);
    _selectedFileName = name;
    notifyListeners();
  }

  void removeAttachment() {
    _selectedFile = null;
    _selectedFileName = null;
    notifyListeners();
  }

  Future<void> getIzinHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await IzinRemoteDatasource().getIzinList();
      result.fold((error) => debugPrint('Gagal mengambil data izin: $error'),
          (data) {
        _listIzin = data
            .map((item) => ModelIzin.fromMap(item as Map<String, dynamic>))
            .toList();
        _listIzin.sort((a, b) => b.id.compareTo(a.id));
      });
    } catch (e) {
      debugPrint('Gagal memproses riwayat izin: $e');
    } finally {
      _isLoading = false;
    }
  }

  bool isIzinFormValid() {
    if (_selectedAlasanIzin == null) return false;
    if (_startDate == null) return false;
    if (descriptionController.text.trim().isEmpty ||
        descriptionController.text.trim().length < 4) return false;

    if (_typeDay == 2) {
      if (_endDate == null) return false;
      if (_endDate!.isBefore(_startDate!)) return false;
    }
    return true;
  }

  void resetForm() {
    _startDate = null;
    _endDate = null;
    _typeDay = 1;
    _selectedFile = null;
    _selectedFileName = null;
    _selectedAlasanIzin = null;
    descriptionController.clear();
    notifyListeners();
  }
}
