import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

import '../models/response/user_response_model.dart';

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
      String email, String password) async {
    final url = Uri.parse('${Variables.baseUrl}/auth/login');

    // 1. Kirim sebagai Map langsung (TANPA jsonEncode) agar dibaca sebagai Form Data
    final response = await http.post(
      url,
      headers: Variables.header(),
      body: {
        'email': email,
        'password': password,
      },
    );

    log("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        // 2. Bongkar JSON respon untuk mengambil objek di dalam key "data"
        final jsonMap = jsonDecode(response.body);
        final dataString = jsonEncode(jsonMap['data']);

        return Right(AuthResponseModel.fromJson(dataString));
      } catch (e) {
        log("Parsing Error: ${e.toString()}");
        return const Left('Gagal memproses format data dari server.');
      }
    } else {
      // Mengambil pesan error dinamis dari backend jika status code bukan 200/201
      try {
        final data = jsonDecode(response.body);
        return Left(data['message'] ?? 'Failed to login');
      } catch (_) {
        return const Left('Failed to login');
      }
    }
  }

  //logout
  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/auth/logout');
    if (authData == null) {
      return const Left('User belum login');
    }

    final response =
        await http.post(url, headers: await Variables.authenticHeaders());

    if (response.statusCode == 200) {
      return const Right('Logout success');
    } else {
      return const Left('Failed to logout');
    }
  }

  Future<Either<String, UserResponseModel>> getProfileMe() async {
    final url = Uri.parse('${Variables.baseUrl}/auth/me');

    final response = await ApiClient.instance.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonMap = jsonDecode(response.body);
        final dataString = jsonEncode(jsonMap['data']);
        return Right(UserResponseModel.fromJson(dataString));
      } catch (e) {
        log('parsing profile error: ${e.toString()}');
        return Left('gagal memproses format data profile');
      }
    }

    try {
      final data = jsonDecode(response.body);
      return Left(data['message'] ?? 'Failed');
    } catch (_) {
      return const Left('Failed');
    }
  }

  Future<Either<String, UserResponseModel>> updateProfileRegisterFace(
    String embedding,
  ) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/update-profile');
    if (authData == null) {
      return const Left('User belum login');
    }

    final request = http.MultipartRequest('POST', url);

    request.fields['face_embedding'] = embedding;

    final response = await ApiClient.instance.multipart(request);

    if (response.statusCode == 200) {
      return Right(UserResponseModel.fromJson(response.body));
    } else {
      return const Left('Failed to update profile');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    final url = Uri.parse('${Variables.baseUrl}/api/update-fcm-token');
    await http.post(
      url,
      headers: await Variables.authenticHeaders(),
      body: jsonEncode({
        'fcm_token': fcmToken,
      }),
    );
  }

  Future<Either<String, AuthResponseModel>> refreshToken() async {
    final authData = await AuthLocalDatasource().getAuthData();

    if (authData == null || authData.refreshToken == null) {
      return const Left('Refresh token tidak ditemukan');
    }

    final url = Uri.parse('${Variables.baseUrl}/auth/refresh');

    final response = await http.post(
      url,
      headers: Variables.header(),
      body: {
        'refresh_token': authData.refreshToken!,
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonMap = jsonDecode(response.body);

        final data = jsonMap['data'];

        // Simpan access token baru, refresh token tetap yang lama
        final updatedAuth = authData.copyWith(
          accessToken: data['access_token'],
          token: data['access_token'],
          tokenType: data['token_type'],
          expiresIn: data['expires_in'],
        );

        await AuthLocalDatasource().saveAuthData(updatedAuth);

        return Right(updatedAuth);
      } catch (e) {
        return Left(e.toString());
      }
    } else {
      await AuthLocalDatasource().removeAuthData();

      try {
        final data = jsonDecode(response.body);
        return Left(data['message'] ?? 'Refresh token gagal');
      } catch (_) {
        return const Left('Refresh token gagal');
      }
    }
  }
}
