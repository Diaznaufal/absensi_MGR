import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  // Fungsi untuk menyimpan data setelah berhasil login
  Future<void> saveAuthData(AuthResponseModel data) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('auth_data', data.toJson());
  }

  // Perbaikan: Menerima objek User langsung dari auth_response_model.dart yang baru
  Future<void> updateAuthData(User user) async {
    final pref = await SharedPreferences.getInstance();
    final authData = await getAuthData();
    if (authData != null) {
      final updatedData = authData.copyWith(user: user);
      await pref.setString('auth_data', updatedData.toJson());
    }
  }

  // Fungsi untuk menghapus sesi saat logout
  Future<void> removeAuthData() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('auth_data');
  }

  // Fungsi untuk mengambil data sesi yang tersimpan
  Future<AuthResponseModel?> getAuthData() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString('auth_data');
    if (data != null) {
      return AuthResponseModel.fromJson(data);
    } else {
      return null;
    }
  }

  // Fungsi untuk mengecek apakah user sudah login atau belum
  Future<bool> isAuth() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString('auth_data');
    return data != null;
  }
}
