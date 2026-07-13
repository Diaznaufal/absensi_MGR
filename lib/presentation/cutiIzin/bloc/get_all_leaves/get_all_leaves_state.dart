part of 'get_all_leaves_bloc.dart';

@freezed
class GetAllLeavesState with _$GetAllLeavesState {
  const factory GetAllLeavesState.initial() = _Initial;
  const factory GetAllLeavesState.loading() = _Loading;
  const factory GetAllLeavesState.success(LeaveResponseModel response) = _Success;
  const factory GetAllLeavesState.error(String message) = _Error;
}
