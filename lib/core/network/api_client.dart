import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../constants/variables.dart';
import '../session/session_manager.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // Menyimpan proses refresh yang sedang berjalan.
  // Semua request 401 akan menunggu Future yang sama.
  Future<bool>? _refreshFuture;

  // =========================
  // GET
  // =========================
  Future<http.Response> get(Uri url) async {
    return _send(() async {
      return await http.get(
        url,
        headers: await Variables.authenticHeaders(),
      );
    });
  }

  // =========================
  // POST
  // =========================
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? body,
  }) async {
    return _send(() async {
      return await http.post(
        url,
        headers: await Variables.authenticHeaders(),
        body: body,
      );
    });
  }

  // =========================
  // PUT
  // =========================
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? body,
  }) async {
    return _send(() async {
      return await http.put(
        url,
        headers: await Variables.authenticHeaders(),
        body: body,
      );
    });
  }

  // =========================
  // DELETE
  // =========================
  Future<http.Response> delete(Uri url) async {
    return _send(() async {
      return await http.delete(
        url,
        headers: await Variables.authenticHeaders(),
      );
    });
  }

  // =========================
  // POST JSON
  // =========================
  Future<http.Response> postJson(
    Uri url, {
    required Map<String, dynamic> body,
  }) async {
    return _send(() async {
      return await http.post(
        url,
        headers: {
          ...(await Variables.authenticHeaders()),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    });
  }

  // =========================
  // MULTIPART
  // =========================
  Future<http.Response> multipart(
    http.MultipartRequest request,
  ) async {
    Future<http.Response> sendRequest() async {
      request.headers.addAll(
        await Variables.authenticHeaders(),
      );

      final streamedResponse = await request.send();

      return await http.Response.fromStream(
        streamedResponse,
      );
    }

    return _send(sendRequest);
  }

  // =========================
  // CENTRAL REQUEST HANDLER
  // =========================
  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    // Request pertama
    http.Response response = await request();

    // Kalau bukan unauthorized,
    // langsung kembalikan response.
    if (response.statusCode != 401) {
      return response;
    }

    print('=================================');
    print('⚠️ API RETURN 401');
    print('⚠️ ACCESS TOKEN EXPIRED');
    print('🔄 MENCOBA REFRESH TOKEN');
    print('=================================');

    // Coba refresh token
    final refreshed = await _refreshToken();

    // =========================
    // REFRESH GAGAL
    // =========================
    if (!refreshed) {
      print('=================================');
      print('❌ REFRESH TOKEN GAGAL');
      print('🚪 SESSION EXPIRED');
      print('🚪 LOGOUT USER');
      print('=================================');

      await _forceLogout();

      return response;
    }

    // =========================
    // REFRESH BERHASIL
    // =========================
    print('=================================');
    print('✅ REFRESH TOKEN BERHASIL');
    print('🔁 MENGULANG REQUEST');
    print('=================================');

    // Request ulang.
    // authenticHeaders() akan dipanggil lagi,
    // sehingga mengambil access token terbaru.
    response = await request();

    // Kalau setelah refresh masih 401,
    // berarti token baru juga tidak valid.
    if (response.statusCode == 401) {
      print('=================================');
      print('❌ RETRY MASIH 401');
      print('🚪 SESSION DIANGGAP EXPIRED');
      print('=================================');

      await _forceLogout();
    }

    return response;
  }

  // =========================
  // REFRESH TOKEN HANDLER
  // =========================
  Future<bool> _refreshToken() async {
    // Kalau sudah ada proses refresh,
    // request lain menunggu proses yang sama.
    if (_refreshFuture != null) {
      print('⏳ Menunggu refresh token berjalan...');

      return await _refreshFuture!;
    }

    // Buat proses refresh baru
    _refreshFuture = _performRefresh();

    try {
      return await _refreshFuture!;
    } finally {
      // Reset setelah selesai
      _refreshFuture = null;
    }
  }

  // =========================
  // PERFORM REFRESH
  // =========================
  Future<bool> _performRefresh() async {
    try {
      print('🔄 Memanggil endpoint refresh token...');

      final result = await AuthRemoteDatasource().refreshToken();

      return result.fold(
        (error) {
          print('❌ Refresh token error: $error');

          return false;
        },
        (success) {
          print('✅ Refresh token success');

          return true;
        },
      );
    } catch (e) {
      print('❌ Exception refresh token: $e');

      return false;
    }
  }

  // =========================
  // FORCE LOGOUT
  // =========================
  Future<void> _forceLogout() async {
    try {
      print('🗑️ Menghapus auth local...');

      // Hapus token/session lokal
      await AuthLocalDatasource().removeAuthData();

      print('✅ Auth local dihapus');

      // Trigger navigasi login
      await SessionManager.instance.sessionExpired();
    } catch (e) {
      print('❌ Force logout error: $e');
    }
  }
}
