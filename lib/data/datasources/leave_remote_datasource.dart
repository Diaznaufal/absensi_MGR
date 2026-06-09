import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/request/create_leave_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/leave_balance_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/leave_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/leave_type_response_model.dart';
import 'package:http/http.dart' as http;

class LeaveRemoteDatasource {
  // Get Leave Types
  Future<Either<String, LeaveTypeResponseModel>> getLeaveTypes() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/leave-types');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(LeaveTypeResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(
            decoded['message']?.toString() ?? 'Failed to fetch leave types');
      } catch (_) {
        return const Left('Failed to fetch leave types');
      }
    }
  }

  // Get Leave Balance
  Future<Either<String, LeaveBalanceResponseModel>> getLeaveBalance({
    String? year,
  }) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final queryParams = year != null ? '?year=$year' : '';
    final url =
        Uri.parse('${Variables.baseUrl}/api/leaves/balance$queryParams');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );

    if (response.statusCode == 200) {
      return Right(LeaveBalanceResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(
            decoded['message']?.toString() ?? 'Failed to fetch leave balance');
      } catch (_) {
        return const Left('Failed to fetch leave balance');
      }
    }
  }

  // Get All Leaves
  Future<Either<String, LeaveResponseModel>> getLeaves({
    String? status,
  }) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final queryParams = status != null ? '?status=$status' : '';
    final url = Uri.parse('${Variables.baseUrl}/api/leaves$queryParams');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.token}',
      },
    );
log("GET LEAVES RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      return Right(LeaveResponseModel.fromJson(response.body));
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(decoded['message']?.toString() ?? 'Failed to fetch leaves');
      } catch (_) {
        return const Left('Failed to fetch leaves');
      }
    }
  }

  // Create Leave Request
  Future<Either<String, String>> createLeave(
    CreateLeaveRequestModel request,
  ) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/leaves');

    final multipartRequest = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${authData?.token}'
      ..headers['Accept'] = 'application/json';

    // Add fields - convert all values to String
    final fields = request.toMap();
    fields.forEach((key, value) {
      multipartRequest.fields[key] = value.toString();
    });

    // Add file if exists
    if (request.attachment != null) {
      final file = await http.MultipartFile.fromPath(
        'attachment',
        request.attachment!.path,
      );
      multipartRequest.files.add(file);
    }

    final streamedResponse = await multipartRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Right('Leave created successfully');
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(decoded['message']?.toString() ?? 'Failed to create leave');
      } catch (_) {
        return const Left('Failed to create leave');
      }
    }
  }
}
