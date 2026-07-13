import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class IzinRemoteDatasource {
  // Ambil data riwayat izin (GET /api/izin)
  Future<Either<String, List<dynamic>>> getIzinList() async {
    final url = Uri.parse('${Variables.baseUrl}/izin');
    final response = await ApiClient.instance.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Right(decoded['data'] as List<dynamic>);
    } else {
      return const Left('Gagal mengambil data izin dari server');
    }
  }

  // Kirim data izin baru (POST /api/izin)
  Future<Either<String, String>> createIzin({
    required String alasanIzin,
    required String tanggalIzin,
    required String description,
    required int typeDay, // 1 = single day, 2 = multi day
    String? endDate,
    File? attachment,
  }) async {
    final url = Uri.parse('${Variables.baseUrl}/izin');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(await Variables
          .authenticHeaders()) // Perbaikan: Langsung masukkan seluruh map header otomatis
      ..fields['alasan_izin'] = alasanIzin
      ..fields['tanggal_izin'] = tanggalIzin
      ..fields['description'] = description
      ..fields['type_day'] = typeDay.toString();

    if (typeDay == 2 && endDate != null) {
      request.fields['end_date'] = endDate;
    }

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'bukti_surat_sakit', // Perbaikan: Sesuaikan key name dengan $_FILES['bukti_surat_sakit'] di Izin.php
          attachment.path,
        ),
      );
    }

    final response = await ApiClient.instance.multipart(request);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(decoded['message'] ?? 'Izin berhasil diajukan');
    } else {
      return Left(decoded['message'] ?? 'Gagal mengajukan izin');
    }
  }
}
