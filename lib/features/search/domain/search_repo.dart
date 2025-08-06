import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';

abstract class SearchRepo {
  Future<List<UserProfile?>> searchUsers(String query);
}
