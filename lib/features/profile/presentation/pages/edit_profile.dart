import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
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
  PlatformFile? imagePickedFile;
  Uint8List? webImage;

  final bioTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.user.bio;
  }

  @override
  void dispose() {
    bioTextController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void updateProfile() {
    final userProfileCubit = context.read<UserProfileCubit>();

    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio = bioTextController.text.isNotEmpty
        ? bioTextController.text
        : null;

    if (imagePickedFile != null || newBio != null) {
      userProfileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
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
          spacing: 10,
          children: [
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: (!kIsWeb && imagePickedFile != null)
                    ? Image.file(
                        File(imagePickedFile!.path!),
                        fit: BoxFit.cover,
                      )
                    : (kIsWeb && webImage != null)
                    ? Image.memory(webImage!, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: widget.user.profileImageUrl,

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
              ),
            ),

            // Pick Image Button
            Center(
              child: MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: Text("Pick Image"),
              ),
            ),

            // Bio
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
                children: [
                  Text("Uploading..."),
                  const SizedBox(height: 10),
                  CircularProgressIndicator(),
                ],
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
        } else if (userProfileState is UserProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to update profile. Please try again."),
            ),
          );
        }
      },
    );
  }
}
