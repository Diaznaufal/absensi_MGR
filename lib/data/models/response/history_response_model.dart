class HistoryDetailModel {
  final String? idAttendance;
  final String? tanggalMasuk;
  final WorkshiftModel? workshift;
  final ProductLocationModel? productLocation;
  final CheckInModel? checkIn;
  final CheckOutModel? checkOut;

  HistoryDetailModel({
    this.idAttendance,
    this.tanggalMasuk,
    this.workshift,
    this.productLocation,
    this.checkIn,
    this.checkOut,
  });

  factory HistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailModel(
      idAttendance: json['id_attendance']?.toString(),
      tanggalMasuk: json['tanggal_masuk'],
      workshift: json['workshift'] != null
          ? WorkshiftModel.fromJson(json['workshift'])
          : null,
      productLocation: json['product_location'] != null
          ? ProductLocationModel.fromJson(json['product_location'])
          : null,
      checkIn: json['check_in'] != null
          ? CheckInModel.fromJson(json['check_in'])
          : null,
      checkOut: json['check_out'] != null
          ? CheckOutModel.fromJson(json['check_out'])
          : null,
    );
  }
}

class WorkshiftModel {
  final String? nameWorkshift;
  final String? clockIn;
  final String? clockOut;

  WorkshiftModel({this.nameWorkshift, this.clockIn, this.clockOut});

  factory WorkshiftModel.fromJson(Map<String, dynamic> json) {
    return WorkshiftModel(
      nameWorkshift: json['name_workshift'],
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
    );
  }
}

class ProductLocationModel {
  final String? idProduct;
  final String? nameProduct;
  final String? latitude;
  final String? longitude;

  ProductLocationModel({
    this.idProduct,
    this.nameProduct,
    this.latitude,
    this.longitude,
  });

  factory ProductLocationModel.fromJson(Map<String, dynamic> json) {
    return ProductLocationModel(
      idProduct: json['id_product']?.toString(),
      nameProduct: json['name_product'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class CheckInModel {
  final String? jamMasuk;
  final bool? timeManagement;
  final String? timeManagementLabel;
  final String? latitude;
  final String? longitude;
  final String? verificationMethod;
  final String? similarityScore;
  final String? photoUrl;

  CheckInModel({
    this.jamMasuk,
    this.timeManagement,
    this.timeManagementLabel,
    this.latitude,
    this.longitude,
    this.verificationMethod,
    this.similarityScore,
    this.photoUrl,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      jamMasuk: json['jam_masuk'],
      timeManagement: json['time_management'],
      timeManagementLabel: json['time_management_label'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      verificationMethod: json['verification_method']?.toString(),
      similarityScore: json['similarity_score']?.toString(),
      photoUrl: json['photo_url'],
    );
  }
}

class CheckOutModel {
  final String? jamKeluar;
  final bool? pulangCepat;
  final String? pulangCepatLabel;
  final String? latitude;
  final String? longitude;
  final String? verificationMethod;
  final String? similarityScore;
  final String? photoUrl;

  CheckOutModel({
    this.jamKeluar,
    this.pulangCepat,
    this.pulangCepatLabel,
    this.latitude,
    this.longitude,
    this.verificationMethod,
    this.similarityScore,
    this.photoUrl,
  });

  factory CheckOutModel.fromJson(Map<String, dynamic> json) {
    return CheckOutModel(
      jamKeluar: json['jam_keluar'],
      pulangCepat: json['pulang_cepat'],
      pulangCepatLabel: json['pulang_cepat_label'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      verificationMethod: json['verification_method_keluar']?.toString(),
      similarityScore: json['similarity_score_keluar']?.toString(),
      photoUrl: json['photo_url'],
    );
  }
}
