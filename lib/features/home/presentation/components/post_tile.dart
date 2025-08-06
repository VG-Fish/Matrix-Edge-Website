import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:matrix_edge_website/features/post/domain/entities/post.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_cubit.dart';
import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/user_profile_cubit.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<UserProfileCubit>();

  bool isOwnPost = false;

  MatrixEdgeUser? currentUser;

  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        userProfile = fetchedUser;
      });
    }
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),

          TextButton(onPressed: widget.onDeletePressed, child: Text("Delete")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              userProfile?.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: userProfile!.profileImageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : const Icon(Icons.person),

              Text(
                "${widget.post.userName}: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              Text(
                "Information: ${widget.post.text}\nAmount: \$${widget.post.amount}",
              ),

              Spacer(),

              if (isOwnPost)
                IconButton(onPressed: showOptions, icon: Icon(Icons.delete)),
            ],
          ),
        ),
      ),
    );
  }
}
