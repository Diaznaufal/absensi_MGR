import 'dart:convert';

class AddpengaduanResponseModel {
  final String? status;
  final String? message;
  final String? kodePengaduan;

  AddpengaduanResponseModel({this.status, this.message, this.kodePengaduan});

  factory AddpengaduanResponseModel.fromJson(String str) =>
      AddpengaduanResponseModel.fromMap(jsonDecode(str));

  factory AddpengaduanResponseModel.fromMap(Map<String, dynamic> json) =>
      AddpengaduanResponseModel(
          status: json["status"]?.toString(),
          message: json["message"],
          kodePengaduan:
              json["data"] != null ? json["data"]["kode_pengaduan"] : null);
}
