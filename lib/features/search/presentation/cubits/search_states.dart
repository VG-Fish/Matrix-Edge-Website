import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<UserProfile?> users;
  SearchLoaded(this.users);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
