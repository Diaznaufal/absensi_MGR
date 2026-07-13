part of 'create_izin_bloc.dart';

@freezed
class CreateIzinState with _$CreateIzinState {
  const factory CreateIzinState.initial() = _Initial;
  const factory CreateIzinState.loading() = _Loading;
  const factory CreateIzinState.success(String message) = _Success;
  const factory CreateIzinState.error(String message) = _Error;
}