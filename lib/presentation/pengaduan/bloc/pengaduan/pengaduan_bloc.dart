import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/model/pengaduan_model.dart';
import 'package:intl/intl.dart';

import 'pengaduan_event.dart';
import 'pengaduan_state.dart';
import '../../../../data/datasources/pengaduan_remote_datasource.dart';

class PengaduanBloc extends Bloc<PengaduanEvent, PengaduanState> {
  final PengaduanRemoteDatasource datasource;

  PengaduanBloc(this.datasource) : super(PengaduanInitial()) {
    on<GetProductsEvent>((event, emit) async {
      emit(GetProductsLoading());

      final result = await datasource.getProducts();

      result.fold(
        (error) {
          emit(PengaduanFailure(error));
        },
        (success) {
          emit(
            GetProductsSuccess(
              success.listProduct ?? [],
            ),
          );
        },
      );
    });

    on<StorePengaduanEvent>((event, emit) async {
      emit(StorePengaduanLoading());

      final result = await datasource.storePengaduan(
        title: event.title,
        text: event.text,
        kategori: event.kategori,
        kategoriLainnya: event.kategoriLainnya,
        idProduct: event.idProduct,
        logoFile: event.logoFile,
      );

      result.fold(
        (error) {
          emit(PengaduanFailure(error));
        },
        (success) {
          emit(
            StorePengaduanSuccess(
              success.message ?? 'Pengaduan berhasil dikirim!',
              success.kodePengaduan ?? '',
            ),
          );
        },
      );
    });

    on<CariPengaduanByKodeEvent>(
      (event, emit) async {
        emit(CariPengaduanLoading());

        final result = await datasource.getPengaduanByKode(
          event.kodePengaduan,
        );

        result.fold(
          (error) {
            if (error.toLowerCase().contains('tidak ditemukan')) {
              emit(CariPengaduanNotFound());
            } else {
              emit(CariPengaduanFailure(error));
            }
          },
          (response) {
            final data = response.data;

            if (data == null) {
              emit(CariPengaduanNotFound());
              return;
            }

            final pengaduan = PengaduanModel(
              kodePengaduan: data.kode ?? '',

              area: '',

              kategori: _parseKategori(
                data.kategori,
              ),

              judul: data.judul ?? '',

              isi: data.pesan ?? '',

              lampiran: const [],

              // Backend mengirim angka status
              status: _parseStatusPengaduan(
                data.status,
              ),

              // Backend mengirim "06-07-2026"
              tanggalPengaduan: _parseTanggal(
                data.tanggal,
              ),
            );

            emit(
              CariPengaduanSuccess(
                pengaduan,
              ),
            );
          },
        );
      },
    );
  }
}

String _parseKategori(String? kategori) {
  switch (kategori?.trim()) {
    case '1':
      return 'Fasilitas Kantor';

    case '2':
      return 'Lingkungan Kerja';

    case '3':
      return 'Pelayanan';

    case '4':
      return 'Lainnya';

    default:
      return '-';
  }
}

statusPengaduan _parseStatusPengaduan(
  String? status,
) {
  switch (status?.toLowerCase().trim()) {
    case '1':
    case 'menunggu':
    case 'Menunggu Diproses':
    case 'menunggu verifikasi':
      return statusPengaduan.menunggu;

    case '2':
    case 'Sedang Diproses':
    case 'dalam proses':
    case 'diproses':
      return statusPengaduan.dalamProses;

    case '3':
    case 'selesai':
    case 'Selesai':
      return statusPengaduan.selesai;

    case '4':
    case 'tidak selesai':
    case 'Tidak Selesai':
      return statusPengaduan.tidakselesai;

    default:
      return statusPengaduan.menunggu;
  }
}

// =============================
// PARSER TANGGAL
// =============================
DateTime _parseTanggal(String? tanggal) {
  if (tanggal == null || tanggal.trim().isEmpty) {
    return DateTime.now();
  }

  try {
    return DateFormat(
      'dd-MM-yyyy',
    ).parseStrict(
      tanggal.trim(),
    );
  } catch (_) {
    return DateTime.now();
  }
}
