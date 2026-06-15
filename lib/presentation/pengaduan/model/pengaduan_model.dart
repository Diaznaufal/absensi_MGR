enum statusPengaduan { menunggu, dalamProses, selesai }

class PengaduanModel {
  final String kodePengaduan;
  final String area;
  final String kategori;
  final String? kategoriLainnya;
  final String judul;
  final String isi;
  final List<String> lampiran;
  final statusPengaduan status;
  final DateTime tanggalPengaduan;

  PengaduanModel(
      {required this.kodePengaduan,
      required this.area,
      required this.kategori,
      this.kategoriLainnya,
      required this.judul,
      required this.isi,
      required this.lampiran,
      required this.status,
      required this.tanggalPengaduan});
}
