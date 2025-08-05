import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';
import 'package:matrix_edge_website/features/profile/domain/repo/user_profile_repo.dart';

class FirebaseUserProfileRepo implements UserProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final userDocument = await firebaseFirestore
          .collection("users")
          .doc(uid)
          .get();

      if (userDocument.exists) {
        final userData = userDocument.data();

        if (userData != null) {
          return UserProfile(
            uid: uid,
            email: userData["email"],
            name: userData["name"],
            bio: userData["bio"] ?? "",
            profileImageUrl: userData["profileImageUrl"].toString(),
          );
        }
        return null;
      }
    } catch (error) {
      return null;
    }
    return null;
  }

  @override
  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(updatedProfile.uid)
          .update({
            "email": updatedProfile.email,
            "name": updatedProfile.name,
            "bio": updatedProfile.bio,
            "profileImageUrl": updatedProfile.profileImageUrl,
          });
    } catch (error) {
      throw Exception("Could not update user due to ${error.toString()}");
    }
  }
}
