import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/post/domain/entities/post.dart';
import 'package:matrix_edge_website/features/post/domain/repositories/post_repo.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_states.dart';
import 'package:matrix_edge_website/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostStates> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
    : super(PostsInitial());

  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    try {
      String? imageUrl;

      // Uploading posts from mobile
      if (imagePath != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }
      // Uploading posts from web
      else if (imageBytes != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);

      postRepo.createPost(newPost);

      fetchAllPosts();
    } catch (error) {
      emit(PostsError("Failed to create post: $error"));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (error) {
      emit(PostsError("Couldn't fetch all posts: $error"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (error) {
      emit(PostsError("Couldn't delete post: $error"));
    }
  }
}
