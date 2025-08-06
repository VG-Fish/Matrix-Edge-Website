import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';
import 'package:matrix_edge_website/features/profile/domain/repo/user_profile_repo.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/profile_states.dart';
import 'package:matrix_edge_website/features/storage/domain/storage_repo.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepo userProfileRepo;
  final StorageRepo storageRepo;

  UserProfileCubit({required this.userProfileRepo, required this.storageRepo})
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

  Future<UserProfile?> getUserProfile(String uid) async {
    final user = await userProfileRepo.fetchUserProfile(uid);
    return user;
  }

  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(UserProfileLoading());

    try {
      final currentUser = await userProfileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(UserProfileError("User not found."));
        return;
      }

      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        if (imageMobilePath != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );
        } else if (imageWebBytes != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
          );
        }

        if (imageDownloadUrl == null) {
          emit(UserProfileError("Unable to upload image."));
          return;
        }
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      await userProfileRepo.updateProfile(updatedProfile);

      await fetchUserProfile(uid);
    } catch (error) {
      emit(UserProfileError("User couldn't be fetched: $error"));
    }
  }
}
