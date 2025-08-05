import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';

abstract class UserProfileRepo {
  Future<UserProfile?> fetchUserProfile(String uid);
  Future<void> updateProfile(UserProfile updatedProfile);
}
