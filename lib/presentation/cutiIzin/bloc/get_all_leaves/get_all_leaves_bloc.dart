import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/leave_response_model.dart';
import '../../model/model_leave.dart';// Pastikan path import ke model_leave.dart Anda sudah benar

part 'get_all_leaves_bloc.freezed.dart';
part 'get_all_leaves_event.dart';
part 'get_all_leaves_state.dart';

class GetAllLeavesBloc extends Bloc<GetAllLeavesEvent, GetAllLeavesState> {
  final LeaveRemoteDatasource datasource;

  GetAllLeavesBloc(
    this.datasource,
  ) : super(const _Initial()) {
    
    on<_GetAllLeaves>((event, emit) async {
      emit(const _Loading());
      
      final result = await datasource.getLeave();
      
      result.fold(
        (l) => emit(_Error(l)),
        (r) {
          // 1. Ubah List<dynamic> dari API menjadi List<LeaveModel> menggunakan fungsi .fromMap
          final parsedLeaves = r.map((item) => LeaveModel.fromMap(item as Map<String, dynamic>)).toList();
          
          // 2. Bungkus ke dalam LeaveResponseModel agar cocok dengan apa yang diminta oleh State _Success
          emit(_Success(LeaveResponseModel(data: parsedLeaves as dynamic)));
        },
      );
    });
  }
}