import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/overtime_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OvertimeRemoteDatasource {
  Future<Either<String, OvertimeResponseModel>> getOvertimes({
    String? month,
  }) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = month != null
        ? Uri.parse('${Variables.baseUrl}/api/overtimes?month=$month')
        : Uri.parse('${Variables.baseUrl}/api/overtimes');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(OvertimeResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(decoded['message']?.toString() ?? 'Failed to get overtimes');
      } catch (_) {
        return const Left('Failed to get overtimes');
      }
    }
  }

  Future<Either<String, OvertimeStatusResponseModel>>
      getOvertimeStatus() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/overtime-status');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(OvertimeStatusResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(
            decoded['message']?.toString() ?? 'Failed to get overtime status');
      } catch (_) {
        return const Left('Failed to get overtime status');
      }
    }
  }

  Future<Either<String, OvertimeSingleResponseModel>> startOvertime({
    String? notes,
    String? reason,
    XFile? startDocumentPath,
  }) async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final url = Uri.parse('${Variables.baseUrl}/api/start-overtime');

      // Log request details
      developer.log(
        '🚀 START OVERTIME REQUEST',
        name: 'OvertimeRemoteDatasource',
      );
      developer.log('URL: $url', name: 'OvertimeRemoteDatasource');
      developer.log('Notes: ${notes ?? "null"}', name: 'OvertimeRemoteDatasource');
      developer.log('Reason: ${reason ?? "null"}', name: 'OvertimeRemoteDatasource');
      developer.log(
        'Document: ${startDocumentPath != null ? startDocumentPath.name : "null"}',
        name: 'OvertimeRemoteDatasource',
      );
      developer.log(
        'Token: ${authData?.token != null ? "Bearer ${authData!.token!.substring(0, 20)}..." : "null"}',
        name: 'OvertimeRemoteDatasource',
      );

      var request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer ${authData?.token}';

      if (notes != null && notes.isNotEmpty) {
        request.fields['notes'] = notes;
        developer.log('✅ Added notes field', name: 'OvertimeRemoteDatasource');
      }
      if (reason != null && reason.isNotEmpty) {
        request.fields['reason'] = reason;
        developer.log('✅ Added reason field', name: 'OvertimeRemoteDatasource');
      }
      if (startDocumentPath != null) {
        final file = await http.MultipartFile.fromPath(
          'start_document_path',
          startDocumentPath.path,
        );
        request.files.add(file);
        developer.log(
          '✅ Added file: ${file.filename} (${file.length} bytes)',
          name: 'OvertimeRemoteDatasource',
        );
      }

      developer.log('📤 Sending request...', name: 'OvertimeRemoteDatasource');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log response
      developer.log(
        '📥 Response Status: ${response.statusCode}',
        name: 'OvertimeRemoteDatasource',
      );
      developer.log(
        '📥 Response Body: ${response.body}',
        name: 'OvertimeRemoteDatasource',
      );
      developer.log(
        '📥 Response Headers: ${response.headers}',
        name: 'OvertimeRemoteDatasource',
      );

      if (response.statusCode == 201) {
        developer.log('✅ SUCCESS', name: 'OvertimeRemoteDatasource');
        return Right(OvertimeSingleResponseModel.fromJson(response.body));
      } else {
        developer.log('❌ FAILED', name: 'OvertimeRemoteDatasource');
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage =
              decoded['message']?.toString() ?? 'Failed to start overtime';
          developer.log('Error Message: $errorMessage',
              name: 'OvertimeRemoteDatasource');

          // Log detailed error if available
          if (decoded['errors'] != null) {
            developer.log(
              'Validation Errors: ${decoded['errors']}',
              name: 'OvertimeRemoteDatasource',
            );
          }

          return Left(errorMessage);
        } catch (e) {
          developer.log(
            'Failed to parse error response: $e',
            name: 'OvertimeRemoteDatasource',
          );
          return const Left('Failed to start overtime');
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        '💥 EXCEPTION: $e',
        name: 'OvertimeRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      return Left('Exception: ${e.toString()}');
    }
  }

  Future<Either<String, OvertimeSingleResponseModel>> endOvertime({
    required int id,
    String? reason,
  }) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/end-overtime');

    final body = {
      'id': id,
      if (reason != null) 'reason': reason,
    };

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Right(OvertimeSingleResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(decoded['message']?.toString() ?? 'Failed to end overtime');
      } catch (_) {
        return const Left('Failed to end overtime');
      }
    }
  }
}
