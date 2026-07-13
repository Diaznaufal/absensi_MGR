part of 'checkout_attendance_bloc.dart';

@freezed
class CheckoutAttendanceEvent with _$CheckoutAttendanceEvent {
  const factory CheckoutAttendanceEvent.started() = _Started;
  const factory CheckoutAttendanceEvent.checkout({
    required double latitude,
    required double longitude,
    required String imagePath,
    required String idSchedule,
  }) = _Checkout;
}