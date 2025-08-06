import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';
import 'package:matrix_edge_website/features/auth/presentation/components/fancy_multiline_text_field.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:matrix_edge_website/features/post/domain/entities/post.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_cubit.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_states.dart';
import 'package:matrix_edge_website/responsive/constrained_scaffold.dart';

class UploadPostsPage extends StatefulWidget {
  const UploadPostsPage({super.key});

  @override
  State<UploadPostsPage> createState() => _UploadPostsPageState();
}

class _UploadPostsPageState extends State<UploadPostsPage> {
  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final TextEditingController informationTextController =
      TextEditingController();
  final TextEditingController amountTextController = TextEditingController();

  MatrixEdgeUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  @override
  void dispose() {
    informationTextController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
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

  void uploadPost() {
    if (imagePickedFile == null ||
        informationTextController.text.isEmpty ||
        amountTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Both image and information are required"),
        ),
      );
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: informationTextController.text,
      amount: amountTextController.text,
      imageUrl: "",
      timestamp: DateTime.now(),
    );

    final postCubit = context.read<PostCubit>();

    // Web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  Widget buildUploadPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload)),
        ],
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            // Image preview for web
            if (kIsWeb && webImage != null) Image.memory(webImage!),

            // Image preview for mobile
            if (!kIsWeb && imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),

            const SizedBox(height: 10),

            // Image of document
            MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("Upload Image"),
            ),

            const SizedBox(height: 10),

            // Information about the document
            FancyMultilineTextField(
              controller: informationTextController,
              hintText: "Enter medical information here",
              obscureText: false,
            ),

            const SizedBox(height: 10),

            // Cost of document
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              controller: amountTextController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                hintText: "Enter amount",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),

                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostStates>(
      builder: (context, postState) {
        if (postState is PostsLoading || postState is PostsUploading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return buildUploadPage();
      },
      listener: (context, postState) {
        if (postState is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }
}
