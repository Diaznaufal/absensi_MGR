import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/variables.dart';
import '../models/response/addpengaduan_response_model.dart';
import '../models/response/productpengaduan_response_model.dart';
import '../models/response/search_pengaduan_model.dart';

class PengaduanRemoteDatasource {
  Future<Either<String, ProductpengaduanResponseModel>> getProducts() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/pengaduan/products');
      final response = await ApiClient.instance.get(url);

      if (response.statusCode == 200) {
        return Right(ProductpengaduanResponseModel.fromJson(response.body));
      } else {
        print("RESPON DARI SERVER: ${response.body}");
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return Left(errorData['message'] ?? 'Gagal mengambil data produk');
      }
    } catch (e) {
      return Left('Terjadi kesalahan jaringan: $e');
    }
  }

  Future<Either<String, AddpengaduanResponseModel>> storePengaduan({
    required String title,
    required String text,
    required String kategori,
    String? kategoriLainnya,
    required String idProduct,
    XFile? logoFile,
  }) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/pengaduan/store');

      final multipartRequest = http.MultipartRequest('POST', url);

      multipartRequest.fields['title_pengaduan'] = title;
      multipartRequest.fields['text_pengaduan'] = text;
      multipartRequest.fields['kategori'] = kategori;
      if (kategori == 'lainnya' && kategoriLainnya != null) {
        multipartRequest.fields['kategori_lainnya'] = kategoriLainnya;
      }
      multipartRequest.fields['id_product'] = idProduct;

      if (logoFile != null) {
        multipartRequest.files
            .add(await http.MultipartFile.fromPath('logo', logoFile.path));
      }

      final response = await ApiClient.instance.multipart(multipartRequest);

      print("STATUS CODE KIRIM PENGADUAN: ${response.statusCode}");
      print("BODY DATA DARI SERVER: ${response.body}");

      if (response.statusCode == 200) {
        return Right(AddpengaduanResponseModel.fromJson(response.body));
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);

        if (errorData['errors'] != null) {
          return Left(errorData['errors'].values.first.toString());
        }
        return Left(errorData['message'] ?? 'Gagal menambahkan pengaduan');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  Future<Either<String, SearchPengaduanResponseModel>> getPengaduanByKode(
      String kodePengaduan) async {
    try {
      final url = Uri.parse(
        '${Variables.baseUrl}/pengaduan/search',
      );

      final response = await ApiClient.instance.post(
        url,
        body: {
          'kode': kodePengaduan,
        },
      );

      print("KODE YANG DIKIRIM: $kodePengaduan");
      print(
        "STATUS CODE CARI PENGADUAN: ${response.statusCode}",
      );
      print(
        "BODY CARI PENGADUAN: ${response.body}",
      );

      if (response.statusCode == 200) {
        return Right(
          SearchPengaduanResponseModel.fromJson(
            response.body,
          ),
        );
      }

      final Map<String, dynamic> errorData = jsonDecode(response.body);

      if (response.statusCode == 404) {
        return Left(
          errorData['message'] ?? 'Kode pengaduan tidak ditemukan',
        );
      }

      // Ambil error validasi field kode
      if (errorData['errors'] != null) {
        final errors = errorData['errors'];

        return Left(
          errors['kode']?.toString() ??
              errorData['message'] ??
              'Validasi gagal',
        );
      }

      return Left(
        errorData['message'] ?? 'Gagal mencari pengaduan',
      );
    } catch (e) {
      return Left(
        'Terjadi kesalahan jaringan: $e',
      );
    }
  }
}
