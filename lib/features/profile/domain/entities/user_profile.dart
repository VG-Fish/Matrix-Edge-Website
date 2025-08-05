import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';

class UserProfile extends MatrixEdgeUser {
  final String bio;
  final String profileImageUrl;

  UserProfile({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
  });

  UserProfile copyWith({String? newBio, String? newProfileImageUrl}) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name,
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "bio": bio,
      "profileImageUrl": profileImageUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json["uid"],
      email: json["email"],
      name: json["name"],
      bio: json["bio"] ?? "",
      profileImageUrl: json["profileImageUrl"] ?? "",
    );
  }
}
