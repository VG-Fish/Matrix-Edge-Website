import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:matrix_edge_website/features/profile/presentation/components/bio_box.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/profile_states.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/user_profile_cubit.dart';
import 'package:matrix_edge_website/features/profile/presentation/pages/edit_profile.dart';

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

          return Scaffold(
            appBar: AppBar(
              title: Text(user.email),
              foregroundColor: theme.colorScheme.primary,
              actions: [
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

            body: Column(
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
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 120,
                  width: 120,
                  padding: EdgeInsets.all(25),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Bio
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Bio: ",
                    style: TextStyle(color: theme.colorScheme.inversePrimary),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 5,
                  ),
                  child: BioBox(text: user.bio),
                ),

                // Posts
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Posts: ",
                    style: TextStyle(color: theme.colorScheme.inversePrimary),
                  ),
                ),

                const SizedBox(height: 10),
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
