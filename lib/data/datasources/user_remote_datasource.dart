import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:flutter_absensi_app/data/models/response/user_response_model.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/variables.dart';
import '../models/request/user_request_model.dart';
import '../models/response/auth_response_model.dart';
import 'auth_local_datasource.dart';

class UserRemoteDatasource {
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
        return Left('gagal memproses format data profile dari server');
      }
    }

    try {
      final data = jsonDecode(response.body);
      return Left(data['message'] ?? 'Failed');
    } catch (_) {
      return const Left('Failed');
    }
  }

  Future<Either<String, User>> updateProfile(
      UserRequestModel model, int id) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final token = authData?.token ?? authData?.accessToken;

    if (token == null) {
      return const Left('Sesi token tidak ditemukan.');
    }

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
      'Accept': 'multipart/form-data'
    };

    var request = http.MultipartRequest(
        'POST', Uri.parse('${Variables.baseUrl}/api/api-user/edit'));

    // Solusi: Lakukan casting eksplisit ke Map<String, String> atau ubah data map menjadi string
    final Map<String, String> fieldsToSend = model.toMap().map(
          (key, value) => MapEntry(key, value.toString()),
        );

    request.fields.addAll(fieldsToSend);

    if (model.image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', model.image!.path));
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final String body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return right(User.fromMap(jsonDecode(body)['data']));
    } else {
      return left(body);
    }
  }
}
