import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/home/presentation/components/homepage_drawer.dart';
import 'package:matrix_edge_website/features/home/presentation/components/post_tile.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_cubit.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_states.dart';
import 'package:matrix_edge_website/features/post/presentation/pages/upload_posts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();

    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadPostsPage()),
            ),
          ),
        ],
      ),

      body: BlocBuilder<PostCubit, PostStates>(
        builder: (context, postState) {
          if (postState is PostsLoading || postState is PostsUploading) {
            return const Center(child: CircularProgressIndicator());
          } else if (postState is PostsLoaded) {
            final allPosts = postState.posts;

            if (allPosts.isEmpty) {
              return const Center(child: Text("No posts yet!"));
            } else {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: allPosts.length,
                  itemBuilder: (context, index) {
                    final post = allPosts[index];

                    return PostTile(
                      post: post,
                      onDeletePressed: () => deletePost(post.id),
                    );
                  },
                ),
              );
            }
          } else if (postState is PostsError) {
            return Center(
              child: Text("Error in fetching posts: ${postState.message}"),
            );
          } else {
            return const SizedBox();
          }
        },
      ),

      drawer: HomepageDrawer(),
    );
  }
}
