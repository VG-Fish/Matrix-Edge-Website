import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrix_edge_website/features/post/domain/entities/post.dart';
import 'package:matrix_edge_website/features/post/domain/repositories/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection("posts");

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (error) {
      throw Exception("Couldn't create post: $error");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postsSnapshot = await postsCollection
          .orderBy("timestamp", descending: true)
          .get();
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (error) {
      throw Exception("Couldn't fetch all posts: $error");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final postsSnapshot = await postsCollection
          .where("userId", isEqualTo: userId)
          .get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (error) {
      throw Exception("Couldn't get posts by $userId: $error");
    }
  }
}
