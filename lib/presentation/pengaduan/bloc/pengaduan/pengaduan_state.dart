import '../../../../data/models/response/productpengaduan_response_model.dart';
import '../../model/pengaduan_model.dart';

abstract class PengaduanState {}

// State awal
class PengaduanInitial extends PengaduanState {}

class GetProductsLoading extends PengaduanState {}

class GetProductsSuccess extends PengaduanState {
  final List<Product> products;

  GetProductsSuccess(this.products);
}

class StorePengaduanLoading extends PengaduanState {}

class StorePengaduanSuccess extends PengaduanState {
  final String message;
  final String kodePengaduan;

  StorePengaduanSuccess(
    this.message,
    this.kodePengaduan,
  );
}

class CariPengaduanLoading extends PengaduanState {}

class CariPengaduanSuccess extends PengaduanState {
  final PengaduanModel pengaduan;

  CariPengaduanSuccess(this.pengaduan);
}

class CariPengaduanNotFound extends PengaduanState {}

class CariPengaduanFailure extends PengaduanState {
  final String message;

  CariPengaduanFailure(this.message);
}

class PengaduanFailure extends PengaduanState {
  final String message;

  PengaduanFailure(this.message);
}
