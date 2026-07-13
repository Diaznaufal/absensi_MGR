import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import '../models/request/create_leave_request_model.dart';
import '../models/response/leave_response_model.dart';
import '../models/response/leave_balance_response_model.dart';
import '../models/response/leave_type_response_model.dart';

class LeaveRemoteDatasource {
  // 1. Untuk LeaveTypeBloc -> Mengembalikan Model khusus Type
  Future<Either<String, LeaveTypeResponseModel>> getLeaveTypes() async {
    final url = Uri.parse('${Variables.baseUrl}/leave/types');
    final response = await ApiClient.instance.get(url);

    if (response.statusCode == 200) {
      return Right(LeaveTypeResponseModel.fromJson(response.body));
    } else {
      return const Left('Gagal mengambil tipe cuti');
    }
  }

  // 2. Untuk LeaveBalanceBloc -> Mengembalikan Model khusus Balance
  Future<Either<String, LeaveBalanceResponseModel>> getLeaveBalance(
      {String? year}) async {
    final queryParams = year != null ? '?year=$year' : '';
    final url = Uri.parse('${Variables.baseUrl}/leave/balance$queryParams');
    final response = await ApiClient.instance.get(url);

    if (response.statusCode == 200) {
      return Right(LeaveBalanceResponseModel.fromJson(response.body));
    } else {
      return const Left('Gagal mengambil kuota cuti');
    }
  }

  // 3. Untuk GetAllLeaves / Riwayat -> Mengembalikan List mentah untuk mapping gabungan
  Future<Either<String, List<dynamic>>> getLeave() async {
    final url = Uri.parse('${Variables.baseUrl}/leave');
    final response = await ApiClient.instance.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Right(decoded['data'] as List<dynamic>);
    } else {
      return const Left('Gagal mengambil data cuti dari server');
    }
  }

  // 4. Untuk CreateLeaveBloc -> Mengembalikan Model khusus Response Create
  Future<Either<String, LeaveResponseModel>> createLeave(
      CreateLeaveRequestModel request) async {
    final url = Uri.parse('${Variables.baseUrl}/leave');

    // Mengekstrak map dari model request secara aman untuk menghindari error nama properti
    final Map<String, dynamic> requestMap = request.toMap();

    // Pemetaan paksa ke format snake_case yang mutlak diminta oleh Laravel/Backend Anda
    final Map<String, String> body = {
      'input_at': DateTime.now()
          .toIso8601String()
          .substring(0, 10), // Format: YYYY-MM-DD
      'type': (requestMap['type'] ?? requestMap['leave_type'] ?? '').toString(),
      'start_day': (requestMap['start_day'] ??
              requestMap['startDay'] ??
              requestMap['startDate'] ??
              '')
          .toString(),
      'end_day': (requestMap['end_day'] ??
              requestMap['endDay'] ??
              requestMap['endDate'] ??
              '')
          .toString(),
      'total_days': (requestMap['total_days'] ?? requestMap['totalDays'] ?? '')
          .toString(),
      'description':
          (requestMap['description'] ?? requestMap['reason'] ?? '').toString(),
    };

    print("======================================");
    print("SENDING REQUEST BODY TO BE:");
    print(body);
    print("======================================");

    // Mengirim body yang sudah rapi ke ApiClient
    final response = await ApiClient.instance.post(
      url,
      body: body,
    );

    print("STATUS CODE : ${response.statusCode}");
    print("RESPONSE BODY : ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(LeaveResponseModel.fromJson(response.body));
    }

    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 422 && decoded['errors'] != null) {
        final Map<String, dynamic> errors = decoded['errors'];
        return Left(errors.values.first.toString());
      }
      return Left(decoded['message'] ?? 'Gagal mengajukan cuti');
    } catch (_) {
      return const Left('Gagal mengajukan cuti');
    }
  }
}
