part of 'get_all_leaves_bloc.dart';

@freezed
class GetAllLeavesEvent with _$GetAllLeavesEvent {
  const factory GetAllLeavesEvent.started() = _Started;
  const factory GetAllLeavesEvent.getAllLeaves({String? status}) = _GetAllLeaves;
}
