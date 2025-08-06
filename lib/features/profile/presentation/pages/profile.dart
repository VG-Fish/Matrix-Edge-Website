import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:matrix_edge_website/features/home/presentation/components/post_tile.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_cubit.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_states.dart';
import 'package:matrix_edge_website/features/profile/presentation/components/bio_box.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/profile_states.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/user_profile_cubit.dart';
import 'package:matrix_edge_website/features/profile/presentation/pages/edit_profile.dart';
import 'package:matrix_edge_website/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final userProfileCubit = context.read<UserProfileCubit>();

  late MatrixEdgeUser? currentUser = authCubit.currentUser;

  int postCount = 0;

  @override
  void initState() {
    super.initState();

    userProfileCubit.fetchUserProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, userProfileState) {
        if (userProfileState is UserProfileLoaded) {
          final user = userProfileState.userProfile;

          return ConstrainedScaffold(
            appBar: AppBar(
              title: Text(user.name),
              foregroundColor: theme.colorScheme.primary,
              actions: [
                if (currentUser?.uid == user.uid)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
              ],
            ),

            body: ListView(
              children: [
                // Email
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(color: theme.colorScheme.inversePrimary),
                  ),
                ),

                const SizedBox(height: 25),

                // Profile picture
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,

                  // Loading image
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),

                  // Loaded image
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Error in loading image
                  errorWidget: (context, url, error) {
                    print("Cached image: $url, $error");

                    return Icon(
                      Icons.person,
                      size: 72,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),

                const SizedBox(height: 25),

                // Bio
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 5,
                  ),
                  child: BioBox(text: user.bio),
                ),

                // Posts
                const SizedBox(height: 10),
                const Divider(height: 5),
                const SizedBox(height: 10),

                BlocBuilder<PostCubit, PostStates>(
                  builder: (context, postState) {
                    if (postState is PostsLoaded) {
                      final userPosts = postState.posts
                          .where((post) => post.userId == widget.uid)
                          .toList();
                      postCount = userPosts.length;
                      return ListView.builder(
                        itemCount: postCount,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          return PostTile(
                            post: post,
                            onDeletePressed: () {
                              var profileCubit = context.read<PostCubit>();
                              profileCubit.deletePost(post.id);
                              profileCubit.fetchAllPosts();
                            },
                          );
                        },
                      );
                    } else if (postState is PostsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text("No posts found."));
                    }
                  },
                ),
              ],
            ),
          );
        } else if (userProfileState is UserProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Center(child: Text("No user found."));
        }
      },
    );
  }
}
