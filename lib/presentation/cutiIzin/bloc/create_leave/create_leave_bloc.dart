// create_leave_bloc.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/request/create_leave_request_model.dart';
import 'package:flutter_absensi_app/data/models/response/leave_response_model.dart';
import 'package:intl/intl.dart';

part 'create_leave_bloc.freezed.dart';
part 'create_leave_event.dart';
part 'create_leave_state.dart';

class CreateLeaveBloc extends Bloc<CreateLeaveEvent, CreateLeaveState> {
  final LeaveRemoteDatasource datasource;

  CreateLeaveBloc(this.datasource) : super(const _Initial()) {
    // Di dalam create_leave_bloc.dart
    on<_CreateLeave>((event, emit) async {
      emit(const _Loading());

      // 1. Ambil startDate
      final start = DateTime.parse(event.startDate);

      // 2. JANGAN pakai (!). Jika endDate null, pakai event.startDate sebagai cadangan
      final endDateStr = event.endDate ?? event.startDate;
      final end = DateTime.parse(endDateStr);

      // 3. Hitung total hari secara aman
      final totalDays = end.difference(start).inDays + 1;
      final typeDay = totalDays == 1 ? 1 : 2;
      final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 4. Masukkan ke model request menggunakan endDateStr yang sudah aman
      final request = CreateLeaveRequestModel(
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: endDateStr, // <-- Pakai string yang sudah divalidasi tadi
        reason: event.reason,
        attachment: event.attachment,
        inputAt: nowStr,
        totalDays: totalDays,
        type: typeDay,
      );

      final result = await datasource.createLeave(request);
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r.message ?? 'Sukses')),
      );
    });
  }
}
