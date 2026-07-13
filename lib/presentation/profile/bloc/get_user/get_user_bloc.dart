import 'package:bloc/bloc.dart';
import 'package:flutter_absensi_app/data/models/response/user_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/user_remote_datasource.dart';
import '../../../../data/models/response/auth_response_model.dart';

part 'get_user_bloc.freezed.dart';
part 'get_user_event.dart';
part 'get_user_state.dart';

class GetUserBloc extends Bloc<GetUserEvent, GetUserState> {
  final UserRemoteDatasource datasource;
  GetUserBloc(
    this.datasource,
  ) : super(_Initial()) {
    on<_GetUser>(
      (event, emit) async {
        emit(_Loading());

        final result = await datasource.getProfileMe();
        result.fold(
          (l) => emit(_Error(l)),
          (r) => emit(_Success(r)),
        );
      },
    );
  }
}
