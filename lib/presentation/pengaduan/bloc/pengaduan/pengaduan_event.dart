import 'package:image_picker/image_picker.dart';

// === EVENTS ===
abstract class PengaduanEvent {}

class GetProductsEvent extends PengaduanEvent {}

class StorePengaduanEvent extends PengaduanEvent {
  final String title;
  final String text;
  final String kategori;
  final String? kategoriLainnya;
  final String idProduct;
  final XFile? logoFile;

  StorePengaduanEvent({
    required this.title,
    required this.text,
    required this.kategori,
    this.kategoriLainnya,
    required this.idProduct,
    this.logoFile,
  });
}

// =============================
// CARI PENGADUAN BERDASARKAN KODE
// =============================
class CariPengaduanByKodeEvent extends PengaduanEvent {
  final String kodePengaduan;

  CariPengaduanByKodeEvent({
    required this.kodePengaduan,
  });
}