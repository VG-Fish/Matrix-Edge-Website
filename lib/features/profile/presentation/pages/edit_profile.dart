import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/presentation/components/fancy_text_field.dart';
import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/profile_states.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/user_profile_cubit.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final bioTextController = TextEditingController();

  void updateProfile() async {
    final userProfileCubit = context.read<UserProfileCubit>();

    if (bioTextController.text.isNotEmpty) {
      userProfileCubit.updateProfile(
        uid: widget.user.uid,
        newBio: bioTextController.text,
      );
    }
  }

  Widget buildEditPage({double uploadProgress = 0.0}) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        foregroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(onPressed: updateProfile, icon: const Icon(Icons.upload)),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Bio"),

            const SizedBox(height: 10),

            FancyTextField(
              controller: bioTextController,
              hintText: "Enter your bio here",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      builder: (context, userProfileState) {
        if (userProfileState is UserProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Uploading..."), CircularProgressIndicator()],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, userProfileState) {
        if (userProfileState is UserProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }
}
