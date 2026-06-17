import '../model/penggajian_model.dart';

// Letakkan ini di file tempat data dummy Anda berada
final List<gajimodel> gajiKaryawan = [
  gajimodel(
    bulan: "Juni 2026",
    tglBayar: "Dibayarkan pada 30 Juni 2026",
    totalGaji: 2500000,
    potongan: 150000,
  ),
  gajimodel(
    bulan: "Mei 2026",
    tglBayar: "Dibayarkan pada 31 Mei 2026",
    totalGaji: 2000000,
    potongan: 0,
  ),
  gajimodel(
    bulan: "April 2026",
    tglBayar: "Dibayarkan pada 30 Apr 2026", // Sudah diperbaiki dari 31 ke 30
    totalGaji: 2100000,
    potongan: 50000,
  ),
];
