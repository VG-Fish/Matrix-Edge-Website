import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:matrix_edge_website/features/auth/data/firebase_auth_repo.dart";
import "package:matrix_edge_website/features/home/presentation/pages/home.dart";
import "package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart";
import "package:matrix_edge_website/features/auth/presentation/cubits/auth_states.dart";
import "package:matrix_edge_website/features/auth/presentation/pages/auth.dart";
import "package:matrix_edge_website/features/post/data/firebase_post_repo.dart";
import "package:matrix_edge_website/features/post/presentation/cubits/post_cubit.dart";
import "package:matrix_edge_website/features/profile/data/firebase_profile_repo.dart";
import "package:matrix_edge_website/features/profile/presentation/cubit/user_profile_cubit.dart";
import "package:matrix_edge_website/features/storage/data/firebase_storage_repo.dart";
import "package:matrix_edge_website/themes/light_mode.dart";

class MatrixEdgeApp extends StatelessWidget {
  final authRepo = FirebaseAuthRepo();
  final userProfileRepo = FirebaseUserProfileRepo();
  final storageRepo = FirebaseStorageRepo();
  final postsRepo = FirebasePostRepo();

  MatrixEdgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),

        BlocProvider<UserProfileCubit>(
          create: (context) => UserProfileCubit(
            userProfileRepo: userProfileRepo,
            storageRepo: storageRepo,
          ),
        ),

        BlocProvider<PostCubit>(
          create: (context) =>
              PostCubit(postRepo: postsRepo, storageRepo: storageRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Unauthenticated) {
              return const AuthPage();
            } else if (authState is Authenticated) {
              return const HomePage();
            } else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
          listener: (context, authState) {
            if (authState is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(authState.message)));
            }
          },
        ),
      ),
    );
  }
}
