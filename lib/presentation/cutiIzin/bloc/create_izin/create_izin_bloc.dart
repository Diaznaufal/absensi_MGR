import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../data/datasources/izin_remote_datasource.dart'; // Sesuaikan path lokasi data source Anda

part 'create_izin_event.dart';
part 'create_izin_state.dart';
part 'create_izin_bloc.freezed.dart';

class CreateIzinBloc extends Bloc<CreateIzinEvent, CreateIzinState> {
  final IzinRemoteDatasource datasource;

  CreateIzinBloc(this.datasource) : super(const _Initial()) {
    on<_CreateIzin>((event, emit) async {
      emit(const _Loading());
      
      final result = await datasource.createIzin(
        alasanIzin: event.alasanIzin,
        tanggalIzin: event.tanggalIzin,
        description: event.description,
        typeDay: event.typeDay,
        endDate: event.endDate,
        attachment: event.attachment,
      );

      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)),
      );
    });
  }
}