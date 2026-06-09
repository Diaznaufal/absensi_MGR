import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PengaduanProvider with ChangeNotifier {
  String? _selectedArea;
  String? get selectedArea => _selectedArea;

  final List<String> _uploadMedia = [];
  List<String> get uploadMedia => _uploadMedia;

  void setSelectedArea(String? newValue) {
    _selectedArea = newValue;
    notifyListeners();
  }

  Future<void> pickMedia(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );

    if (result != null && result.files.single.path != null) {
      PlatformFile file = result.files.single;

      // Batasan 4 MB
      int maxSizeBytes = 4 * 1024 * 1024;

      if (file.size > maxSizeBytes) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal! Ukuran gambar melebihi 4 MB."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Jika lolos, masukkan ke list
      _uploadMedia.add(file.path!);
      notifyListeners();
    }
  }

  void removeMedia(String path) {
    _uploadMedia.remove(path);
    notifyListeners();
  }

  void resetFrom() {
    _selectedArea = null;
    _uploadMedia.clear();
    notifyListeners();
  }
}
