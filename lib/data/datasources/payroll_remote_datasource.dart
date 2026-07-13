import 'package:dartz/dartz.dart';
import '../models/response/payroll_response_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/variables.dart';

class PayrollRemoteDatasource {
  PayrollRemoteDatasource._();

  static final PayrollRemoteDatasource instance = PayrollRemoteDatasource._();

  /// 1. Get Current Payroll (Dashboard Card)
  Future<Either<String, PayrollResponseModel>> getCurrentPayroll() async {
    final url = Uri.parse('${Variables.baseUrl}/payroll/current');

    try {
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(PayrollResponseModel.fromJson(response.body));
      } else {
        return Left(
            'Gagal memuat data payroll saat ini (Status: ${response.statusCode})');
      }
    } catch (e) {
      return Left('Terjadi kesalahan koneksi: $e');
    }
  }

  /// 2. Get Payroll History Berdasarkan Tahun
  Future<Either<String, PayrollResponseModel>> getPayrollHistory(
      int year) async {
    final url = Uri.parse('${Variables.baseUrl}/payroll/history?year=$year');

    try {
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(PayrollResponseModel.fromJson(response.body));
      } else {
        return Left(
            'Gagal memuat riwayat payroll tahun $year (Status: ${response.statusCode})');
      }
    } catch (e) {
      return Left('Terjadi kesalahan koneksi: $e');
    }
  }

  /// 3. Get Payroll Detail Berdasarkan ID
  Future<Either<String, PayrollResponseModel>> getPayrollDetail(
      int idPayrollComponent) async {
    final url =
        Uri.parse('${Variables.baseUrl}/payroll/detail/$idPayrollComponent');

    try {
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(PayrollResponseModel.fromJson(response.body));
      } else {
        return Left(
            'Gagal memuat detail payroll ID $idPayrollComponent (Status: ${response.statusCode})');
      }
    } catch (e) {
      return Left('Terjadi kesalahan koneksi: $e');
    }
  }
}
