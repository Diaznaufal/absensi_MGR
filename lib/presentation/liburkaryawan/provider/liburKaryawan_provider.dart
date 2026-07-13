import 'package:flutter/material.dart';
import '../model/liburKaryawan_model.dart';

class LiburkaryawanProvider with ChangeNotifier {
  final LiburkaryawanModel _userShift = LiburkaryawanModel(
    id: "user",
    nama: "Diaz",
    role: "Staff",
    avatarUrl: 'avatarUrl',
    date: DateTime(2026, 04, 16),
    shiftName: "Shift Pagi",
    timeRange: "08.00 - 17.00",
  );

  final List<LiburkaryawanModel> _karyawanLain = [
    LiburkaryawanModel(
        id: "EMP001",
        nama: "Ahmad Fauzi",
        role: "Staff Oprasional",
        avatarUrl: '',
        date: DateTime(2026, 04, 16),
        shiftName: "Shift Malam",
        timeRange: "20.00 - 05.00"),
    LiburkaryawanModel(
        id: "EMP002",
        nama: "Budi Santoso",
        role: "Kasir",
        avatarUrl: 'avatarUrl',
        date: DateTime(2026, 04, 16),
        shiftName: "Shift Siang",
        timeRange: "13.00 - 21.00")
  ];

  final List<submitLiburKaryawan> _historiList = [];

  LiburkaryawanModel get userShift => _userShift;
  List<LiburkaryawanModel> get karyawanLain => _karyawanLain;
  List<submitLiburKaryawan> get historiList => _historiList;

  void addSubmit(submitLiburKaryawan submit) {
    _historiList.insert(0, submit);
    notifyListeners();
  }
}
