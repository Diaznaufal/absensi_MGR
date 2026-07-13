part of 'is_checkedin_bloc.dart';

@freezed
class IsCheckedinState with _$IsCheckedinState {
  const factory IsCheckedinState.initial() = _Initial;
  const factory IsCheckedinState.loading() = _Loading;
  // Mengubah parameter success untuk membawa Map data dari /absence/today
  const factory IsCheckedinState.success(Map<String, dynamic> absenceData) = _Success;
  const factory IsCheckedinState.error(String message) = _Error;
}