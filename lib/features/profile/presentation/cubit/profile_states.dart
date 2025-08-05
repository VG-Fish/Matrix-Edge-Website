import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile userProfile;

  UserProfileLoaded(this.userProfile);
}

class UserProfileError extends UserProfileState {
  final String message;

  UserProfileError(this.message);
}
