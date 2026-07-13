import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';

class Variables {
  static const String appName = 'Absensi MGR';
  static const String baseUrl = 'https://testing.multigraharadhika.co.id/api';

  static Map<String, String> header() {
    return {
      'Accept': 'application/json',
      'X-API-KEY': 'mgr-api-10519190',
    };
  }

  // Dibuat async agar otomatis mengambil token user yang sedang login
  static Future<Map<String, String>> authenticHeaders() async {
    final authData = await AuthLocalDatasource().getAuthData();

    return {
      'Accept': 'application/json',
      'X-API-KEY': 'mgr-api-10519190',
      'Authorization': 'Bearer ${authData?.accessToken ?? authData?.token}',
    };
  }
}
