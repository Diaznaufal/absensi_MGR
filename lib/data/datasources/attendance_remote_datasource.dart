import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:flutter_absensi_app/core/network/api_client.dart';
import 'package:flutter_absensi_app/data/models/request/checkinout_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/checkinout_response_model.dart';
import 'package:flutter_absensi_app/data/models/response/company_response_model.dart';
import '../models/response/history_response_model.dart';
import 'package:http/http.dart' as http;

class AttendanceRemoteDatasource {
  // ==================== COMPANY PROFILE ====================
  /// Mengambil profil instansi/perusahaan menggunakan ApiClient agar mendukung refresh token
  Future<Either<String, CompanyResponseModel>> getCompanyProfile() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/company');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(CompanyResponseModel.fromJson(response.body));
      } else {
        return const Left('Gagal mengambil profil perusahaan');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  // ==================== IS CHECKED IN STATUS ====================
  Future<Either<String, (bool, bool)>> isCheckedin() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/is-checkin');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Right((
          responseData['checkedin'] as bool,
          responseData['checkedout'] as bool
        ));
      } else {
        return const Left('Gagal memuat status check-in');
      }
    } catch (e) {
      return Left('Terjadi kesalahan jaringan: $e');
    }
  }

  // ========================== REGISTER FACE (api/face/register) ==========================
  /// Mendaftarkan template biometrik wajah pertama kali via ApiClient.instance.multipart
  Future<Either<String, String>> registerFace(String imagePath) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/face/register');
      var request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath('photo', imagePath),
      );

      // ApiClient.instance.multipart otomatis menambahkan header autentikasi secara dinamis
      final response = await ApiClient.instance.multipart(request);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Right(
          decoded['message']?.toString() ?? 'Pendaftaran wajah berhasil!',
        );
      } else {
        try {
          final decoded = jsonDecode(response.body);
          return Left(
            decoded['message']?.toString() ?? 'Gagal mendaftarkan wajah',
          );
        } catch (_) {
          return Left(
              'Gagal mendaftarkan wajah (Status: ${response.statusCode})');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan jaringan: $e');
    }
  }

  // ==================== COMBINED FACE RECOGNITION & CHECK-IN ====================
  /// Melakukan absensi masuk dengan validasi wajah dan titik lokasi GPS terintegrasi
  Future<Either<String, CheckInOutResponseModel>> checkinWithFace({
    required CheckInOutRequestModel data,
    required String imagePath,
    required String idSchedule,
  }) async {
    try {
      final checkinUrl = Uri.parse('${Variables.baseUrl}/absence/check-in');
      var checkinRequest = http.MultipartRequest('POST', checkinUrl);

      checkinRequest.fields['id_schedule'] = idSchedule;
      checkinRequest.fields['latitude'] = data.latitude.toString();
      checkinRequest.fields['longitude'] = data.longitude.toString();

      checkinRequest.files.add(
        await http.MultipartFile.fromPath('photo', imagePath),
      );

      final checkinResponse =
          await ApiClient.instance.multipart(checkinRequest);

      if (checkinResponse.statusCode == 200) {
        return Right(CheckInOutResponseModel.fromJson(checkinResponse.body));
      } else {
        // 🆕 CETAK LANGSUNG KE CONSOLE: Mengetahui alasan penolakan asli server saat tes di HP
        print(
            '🚨 SERVER RESPONSE ERROR (Code ${checkinResponse.statusCode}): ${checkinResponse.body}');

        try {
          final decoded =
              jsonDecode(checkinResponse.body) as Map<String, dynamic>;

          // Membaca pesan error secara dinamis dari berbagai key umum REST API (CodeIgniter/Laravel)
          final serverMessage =
              decoded['message'] ?? decoded['error'] ?? decoded['msg'];

          if (serverMessage != null) {
            return Left(serverMessage.toString());
          }

          // Jika struktur JSON tidak dikenal, kirim status code beserta isi body mentahnya
          return Left(
              'Gagal Server (${checkinResponse.statusCode}): ${checkinResponse.body}');
        } catch (_) {
          return Left(
              'Gagal Server (${checkinResponse.statusCode}). Raw: ${checkinResponse.body}');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan sistem: $e');
    }
  }

  // ==================== GET ABSENCE HISTORY (api/absence/history) ====================
  Future<Either<String, AttendanceResponseModel>> getAbsenceHistory({
    required String month,
    required String year,
  }) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/absence/history');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(AttendanceResponseModel.fromJson(response.body));
      } else {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(
              decoded['message']?.toString() ?? 'Gagal mengambil riwayat');
        } catch (_) {
          return const Left('Gagal memuat riwayat absensi');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  //====================== CHECK FACE REGISTRATION STATUS ===================

  Future<Either<String, bool>> checkFaceRegistrationStatus() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/face/status');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Right(decoded['data']['has_registered_face'] == true);
      } else if (response.statusCode == 404) {
        return const Right(false);
      } else {
        return const Left('Gagal mengecek status registrasi wajah');
      }
    } catch (e) {
      return Left('Terjadi gangguan koneksi: $e');
    }
  }

  Future<Either<String, Map<String, dynamic>>> getScheduleToday() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/schedule/today');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Right(decoded['data'] ?? {});
      } else {
        return const Left('Tidak ditemukan jadwal kerja aktif untuk hari ini');
      }
    } catch (e) {
      return Left('Gagal mendapatkan jadwal hari ini: $e');
    }
  }

  // 2. GET SCHEDULE MONTH (api/schedule/month)
  /// Digunakan untuk menyuplai rekap data kalender kerja bulanan karyawan
  Future<Either<String, List<dynamic>>> getScheduleMonth({
    required String month,
    required String year,
  }) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/schedule/month?month=$month&year=$year');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Right(decoded['data'] ?? []);
      } else {
        return const Left('Gagal memuat jadwal bulanan');
      }
    } catch (e) {
      return Left('Terjadi masalah jaringan: $e');
    }
  }

  // ==================== COMBINED FACE RECOGNITION & CHECK-OUT ====================
  /// Melakukan absensi pulang dengan validasi wajah dan titik lokasi GPS terintegrasi
  Future<Either<String, CheckInOutResponseModel>> checkoutWithFace({
    required CheckInOutRequestModel data,
    required String imagePath,
    required String idSchedule,
  }) async {
    try {
      final checkoutUrl = Uri.parse('${Variables.baseUrl}/absence/check-out');
      var checkoutRequest = http.MultipartRequest('POST', checkoutUrl);

      checkoutRequest.fields['id_schedule'] = idSchedule;
      checkoutRequest.fields['latitude'] = data.latitude.toString();
      checkoutRequest.fields['longitude'] = data.longitude.toString();

      checkoutRequest.files.add(
        await http.MultipartFile.fromPath('photo', imagePath),
      );

      final checkoutResponse =
          await ApiClient.instance.multipart(checkoutRequest);

      if (checkoutResponse.statusCode == 200) {
        return Right(CheckInOutResponseModel.fromJson(checkoutResponse.body));
      } else {
        print(
            '🚨 SERVER RESPONSE ERROR (Code ${checkoutResponse.statusCode}): ${checkoutResponse.body}');

        try {
          final decoded =
              jsonDecode(checkoutResponse.body) as Map<String, dynamic>;
          final serverMessage =
              decoded['message'] ?? decoded['error'] ?? decoded['msg'];

          if (serverMessage != null) {
            return Left(serverMessage.toString());
          }
          return Left(
              'Gagal Server (${checkoutResponse.statusCode}): ${checkoutResponse.body}');
        } catch (_) {
          return Left(
              'Gagal Server (${checkoutResponse.statusCode}). Raw: ${checkoutResponse.body}');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan sistem: $e');
    }
  }

  // ==================== GET ABSENCE TODAY (api/absence/today) ====================
  /// Mengambil status absensi hari ini (has_schedule, jam_masuk, already_checked_in, dll)
  Future<Either<String, Map<String, dynamic>>> getAbsenceToday() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/absence/today');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Right(decoded['data'] ?? {});
      } else {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(decoded['message']?.toString() ??
              'Gagal memuat status absensi hari ini');
        } catch (_) {
          return const Left('Gagal memuat status absensi hari ini');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan jaringan: $e');
    }
  }

// ========================== GET SCHEDULE BY MONTH ==========================
  Future<Either<String, AttendanceResponseModel>> getScheduleByMonth({
    required String month,
    required String year,
  }) async {
    try {
      // Menambahkan query parameter month dan year secara otomatis
      final url = Uri.parse(
          '${Variables.baseUrl}/schedule/month?year=$year&month=$month');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(AttendanceResponseModel.fromJson(response.body));
      } else {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(
            decoded['message']?.toString() ?? 'Gagal mengambil jadwal bulanan',
          );
        } catch (_) {
          return const Left('Gagal memuat jadwal bulanan');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  Future<Either<String, AttendanceResponseModel>> getAbsenceAll() async {
    try {
      // Menambahkan query parameter month dan year secara otomatis
      final url = Uri.parse('${Variables.baseUrl}/absence/historyAll');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(AttendanceResponseModel.fromJson(response.body));
      } else {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(
            decoded['message']?.toString() ?? 'Gagal mengambil history all',
          );
        } catch (_) {
          return const Left('Gagal memuat jadwal bulanan');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  Future<Either<String, HistoryDetailModel>> getHistoryDetail(
      {required String idAttendance}) async {
    try {
      // Menambahkan query parameter month dan year secara otomatis
      final url = Uri.parse(
          '${Variables.baseUrl}/absence/historyDetail?id_attendance=$idAttendance');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final detailJson = decoded['data'] as Map<String, dynamic>;

        return Right(HistoryDetailModel.fromJson(detailJson));
      } else {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(
            decoded['message']?.toString() ?? 'Gagal mengambil detail history',
          );
        } catch (_) {
          return const Left('Gagal memuat jadwal bulanan');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }
}
