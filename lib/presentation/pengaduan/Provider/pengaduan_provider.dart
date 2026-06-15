import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';

class PengaduanProvider with ChangeNotifier {
  PengaduanProvider() {
    judulPengaduanController.addListener(notifyListeners);
    isiPengaduanController.addListener(notifyListeners);
    kategoriLainnyaController.addListener(notifyListeners);
  }

  String? _selectedArea;
  String? _selectedKategori;

  String? get selectedArea => _selectedArea;
  String? get selectedKategori => _selectedKategori;

  final List<String> _uploadMedia = [];
  List<String> get uploadMedia => _uploadMedia;

  final List<PengaduanModel> _listPengaduan = [];
  List<PengaduanModel> get listPengaduan => _listPengaduan;

  final TextEditingController kategoriLainnyaController =
      TextEditingController();

  final TextEditingController judulPengaduanController =
      TextEditingController();

  final TextEditingController isiPengaduanController = TextEditingController();

  void setSelectedArea(String? newValue) {
    _selectedArea = newValue;
    notifyListeners();
  }

  void setSelectedKategori(String? newValue) {
    _selectedKategori = newValue;

    if (_selectedKategori != '4') {
      kategoriLainnyaController.clear();
    }

    notifyListeners();
  }

  String generateKodePengaduan() {
    final now = DateTime.now();
    final random = Random();

    final randomNumber = (100 + random.nextInt(900)).toString();

    return "MGR-"
        "${(now.year % 100).toString().padLeft(2, '0')}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}"
        "-$randomNumber";
  }

  Future<void> pickMedia(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );

    if (result != null && result.files.single.path != null) {
      PlatformFile file = result.files.single;

      const int maxSizeBytes = 4 * 1024 * 1024;

      if (file.size > maxSizeBytes) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal! Ukuran gambar melebihi 4 MB.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      _uploadMedia.add(file.path!);
      notifyListeners();
    }
  }

  void removeMedia(String path) {
    _uploadMedia.remove(path);
    notifyListeners();
  }

  void tambahPengaduan(PengaduanModel pengaduan) {
    _listPengaduan.insert(0, pengaduan);
    notifyListeners();
  }

  bool isFormValid() {
    if (_selectedArea == null) return false;
    if (_selectedKategori == null) return false;

    if (judulPengaduanController.text.trim().isEmpty) {
      return false;
    }

    if (isiPengaduanController.text.trim().isEmpty) {
      return false;
    }

    if (_selectedKategori == '4' &&
        kategoriLainnyaController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  void resetFrom() {
    _selectedArea = null;
    _selectedKategori = null;

    _uploadMedia.clear();

    kategoriLainnyaController.clear();
    judulPengaduanController.clear();
    isiPengaduanController.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    kategoriLainnyaController.dispose();
    judulPengaduanController.dispose();
    isiPengaduanController.dispose();
    super.dispose();
  }
}
