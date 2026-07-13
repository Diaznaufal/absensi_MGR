part of 'create_izin_bloc.dart';

@freezed
class CreateIzinEvent with _$CreateIzinEvent {
  const factory CreateIzinEvent.started() = _Started;
  const factory CreateIzinEvent.createIzin({
    required String alasanIzin,
    required String tanggalIzin,
    required String description,
    required int typeDay,
    String? endDate,
    File? attachment,
    required String inputAt
  }) = _CreateIzin;
}