import 'dart:convert';

class SearchPengaduanResponseModel {
  final bool? status;
  final String? message;
  final SearchPengaduanData? data;

  SearchPengaduanResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory SearchPengaduanResponseModel.fromJson(String str) {
    return SearchPengaduanResponseModel.fromMap(
      jsonDecode(str),
    );
  }

  factory SearchPengaduanResponseModel.fromMap(
    Map<String, dynamic> json,
  ) {
    return SearchPengaduanResponseModel(
      status: json['status'],
      message: json['message']?.toString(),
      data: json['data'] == null
          ? null
          : SearchPengaduanData.fromMap(
              json['data'],
            ),
    );
  }
}

class SearchPengaduanData {
  final String? id;
  final String? kode;
  final String? kategori;
  final String? judul;
  final String? tanggal;
  final String? lampiran;
  final String? status;
  final String? pesan;

  SearchPengaduanData({
    this.id,
    this.kode,
    this.kategori,
    this.judul,
    this.tanggal,
    this.lampiran,
    this.status,
    this.pesan,
  });

  factory SearchPengaduanData.fromMap(
    Map<String, dynamic> json,
  ) {
    return SearchPengaduanData(
      id: json['id']?.toString(),
      kode: json['kode']?.toString(),
      kategori: json['kategori']?.toString(),
      judul: json['judul']?.toString(),
      tanggal: json['tanggal']?.toString(),
      lampiran: json['lapiran']?.toString(),
      status: json['status']?.toString(),
      pesan: json['pesan']?.toString(),
    );
  }
}