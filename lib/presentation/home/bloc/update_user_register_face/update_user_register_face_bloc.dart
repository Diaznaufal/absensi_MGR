import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';

import '../../../../data/models/response/user_response_model.dart';

part 'update_user_register_face_bloc.freezed.dart';
part 'update_user_register_face_event.dart';
part 'update_user_register_face_state.dart';

class UpdateUserRegisterFaceBloc
    extends Bloc<UpdateUserRegisterFaceEvent, UpdateUserRegisterFaceState> {
  final AuthRemoteDatasource authRemoteDatasource;

  // Datasource khusus untuk Face ID / Face Recognition (terpisah dari foto
  // profil). Tidak diwajibkan lewat constructor supaya tidak mengubah
  // tempat-tempat lain yang sudah memanggil `UpdateUserRegisterFaceBloc(authRemoteDatasource)`.
  final AttendanceRemoteDatasource attendanceRemoteDatasource;

  UpdateUserRegisterFaceBloc(
    this.authRemoteDatasource, {
    AttendanceRemoteDatasource? attendanceRemoteDatasource,
  })  : attendanceRemoteDatasource =
            attendanceRemoteDatasource ?? AttendanceRemoteDatasource(),
        super(const _Initial()) {
    on<_UpdateProfileRegisterFace>((event, emit) async {
      emit(const _Loading());
      try {
        // PENTING:
        // event.embedding di sini sebenarnya berisi PATH FILE GAMBAR wajah
        // (bukan string embedding biometrik). File ini harus di-upload
        // sebagai multipart file ke endpoint khusus Face ID
        // (/api/face/register), BUKAN dikirim sebagai field text ke
        // endpoint update-profile (/api/update-profile) milik foto profil.
        //
        // Sebelumnya kode ini salah memanggil
        // `authRemoteDatasource.updateProfileRegisterFace(event.embedding)`
        // yang mengirim path file sebagai field text 'face_embedding' ke
        // endpoint Auth, sehingga backend menolaknya dengan
        // "Failed to update profile".
        final imagePath = event.embedding;
        log('📤 [Bloc] Mengirim file Face ID ke /api/face/register: $imagePath');

        final result =
            await this.attendanceRemoteDatasource.registerFace(imagePath);

        await result.fold(
          (l) async {
            log('❌ [Bloc] Gagal registrasi Face ID: $l');
            emit(_Error(l));
          },
          (message) async {
            // message = pesan sukses (String) dari server,
            // misal: "Pendaftaran wajah berhasil!"
            // Pesan ini HANYA dipakai untuk log, TIDAK dipakai untuk emit,
            // karena _Success butuh UserResponseModel, bukan String.
            log('✅ [Bloc] Registrasi Face ID berhasil: $message');

            // CATATAN PENTING soal tipe data:
            // - `authData.user` (dari AuthLocalDatasource) bertipe `User`
            //   (didefinisikan di auth_response_model.dart).
            // - `_Success` di state butuh tipe `UserResponseModel`
            //   (file terpisah: user_response_model.dart).
            // Dua tipe ini BEDA CLASS meskipun namanya mirip-mirip,
            // jadi tidak bisa saling dipakai langsung. Karena itu:
            //   1. Untuk update local storage -> tetap pakai `authData.user`
            //      (tipe `User`), sesuai yang diminta `updateAuthData()`.
            //   2. Untuk emit(_Success(...)) -> ambil ulang data terbaru
            //      lewat `getProfileMe()` yang me-return `UserResponseModel`.

            try {
              // Mengambil session user yang saat ini ada di local storage HP
              final authData = await AuthLocalDatasource().getAuthData();

              if (authData != null && authData.user != null) {
                // Buat data user tiruan lokal yang menandakan wajah sudah terdaftar.
                // Sesuaikan jika ada field flag spesifik di model User-mu,
                // misal: isFaceRegistered: true
                final updatedUser = authData.user!; // tipe: User

                // Simpan ulang ke local storage agar session tetap aktif
                await AuthLocalDatasource().updateAuthData(updatedUser);
              }
            } catch (e) {
              log('⚠️  [Bloc] Gagal memperbarui data lokal setelah registrasi wajah: $e');
              // Tidak masalah meskipun mapping data lokal gagal,
              // tetap lanjut emit sukses karena registrasi wajah di server berhasil.
            }

            // Ambil ulang profil dari server untuk dapat UserResponseModel
            // yang valid (tipe yang dibutuhkan oleh _Success).
            final profileResult = await authRemoteDatasource.getProfileMe();

            profileResult.fold(
              (profileError) {
                log('⚠️  [Bloc] Registrasi wajah sukses tapi gagal ambil ulang profil: $profileError');
                emit(_Error(
                  'Wajah berhasil didaftarkan, tetapi gagal memuat ulang data profil: $profileError',
                ));
              },
              (freshUserResponse) {
                emit(_Success(freshUserResponse));
              },
            );
          },
        );
      } catch (e, stack) {
        log('❌ [Bloc] Exception saat registrasi Face ID: $e\n$stack');
        emit(_Error(e.toString()));
      }
    });
  }
}
