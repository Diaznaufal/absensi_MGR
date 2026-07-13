import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:flutter_absensi_app/data/models/response/liburkaryawan_response_model.dart';

class DayOffRemoteDatasource {
  Future<Either<String, DayOffResponseModel>> getDayOff() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/day-off');

      final response = await ApiClient.instance.get(url);
      if (response.statusCode == 200) {
        return Right(DayOffResponseModel.fromJson(response.body));
      } else {
        return const Left('Gagal mengambil data day off');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  Future<Either<String, DayOffResponseModel>> addDayOff({
    required String inputAt,
    required String tglDayOff,
    required String description,
  }) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/day-off');

      final Map<String, dynamic> body = {
        'input_at': inputAt,
        'tgl_day_off': tglDayOff,
        'description': description
      };

      final response = await ApiClient.instance.postJson(url, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(DayOffResponseModel.fromJson(response.body));
      } else {
        return const Left('Gagal menambahkan data day off');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }
}
