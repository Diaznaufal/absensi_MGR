import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OvertimeRemoteDatasource {
  Future<Either<String, OvertimeResponseModel>> getOvertimes(
      {String? month}) async {
    final url = month != null
        ? Uri.parse('${Variables.baseUrl}/overtime?month=$month')
        : Uri.parse('${Variables.baseUrl}/overtime');

    final response = await ApiClient.instance.get(url);

    if (response.statusCode == 200) {
      return Right(OvertimeResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(
            decoded['message']?.toString() ?? ' Failed to get overtime');
      } catch (_) {
        return Left('Failed to get overtime');
      }
    }
  }

  Future<Either<String, OvertimeResponseModel>> createOvertime(
      {required String date,
      required String startTime,
      required String endTime,
      required String timeSpend,
      required String description}) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/overtime');
      developer.log('🚀 POST CREATE OVERTIME VIA API CLIENT',
          name: 'OvertimeRemoteDatasource');

      final body = {
        'input_at': date,
        'tanggal': date,
        'time_spend': timeSpend,
        'start': '$startTime:00',
        'end': '$endTime:00',
        'description': description,
      };

      final response = await ApiClient.instance.postJson(url, body: body);

      developer.log('📥 Status Code: ${response.statusCode}',
          name: 'OvertimeRemoteDatasource');
      developer.log('📥 Response Body: ${response.body}',
          name: 'OvertimeRemoteDatasource');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(OvertimeResponseModel.fromJson(response.body));
      } else {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(
              decoded['message']?.toString() ?? ' Gagal mengajukan lembur');
        } catch (_) {
          return Left('Gagal mengajukan lembur');
        }
      }
    } catch (e) {
      return Left('Exception: ${e.toString()}');
    }
  }
}
