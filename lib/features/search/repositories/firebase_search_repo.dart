import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';
import 'package:matrix_edge_website/features/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<UserProfile?>> searchUsers(String query) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection("users")
          .where("name", isGreaterThanOrEqualTo: query)
          .where(
            "name",
            isLessThanOrEqualTo: "$query\u8fff",
          ) // u8fff expands the search range to include all possible queries.
          .get();
      return result.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (error) {
      throw Exception("Error fetching users: $error");
    }
  }
}
