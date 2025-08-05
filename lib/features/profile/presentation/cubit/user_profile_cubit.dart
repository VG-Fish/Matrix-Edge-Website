import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/profile/domain/repo/user_profile_repo.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/profile_states.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepo userProfileRepo;

  UserProfileCubit({required this.userProfileRepo})
    : super(UserProfileInitial());

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(UserProfileLoading());
      final user = await userProfileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(UserProfileLoaded(user));
      } else {
        emit(UserProfileError("User not found."));
      }
    } catch (error) {
      emit(UserProfileError("Error occurred: ${error.toString()}"));
    }
  }

  Future<void> updateProfile({required String uid, String? newBio}) async {
    emit(UserProfileLoading());

    try {
      final currentUser = await userProfileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(UserProfileError("User not found"));
        return;
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
      );

      await userProfileRepo.updateProfile(updatedProfile);

      await fetchUserProfile(uid);
    } catch (error) {
      emit(UserProfileError("User couldn't be fetched: $error"));
    }
  }
}
