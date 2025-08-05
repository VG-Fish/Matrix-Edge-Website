import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/presentation/components/basic_button.dart';
import 'package:matrix_edge_website/features/auth/presentation/components/fancy_text_field.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() {
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    final authCubit = context.read<AuthCubit>();

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        authCubit.register(name, email, password);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords don't match!")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields!")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top icon
                Icon(
                  Icons.lock,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 50),

                // Create account text
                Text(
                  "Create an account!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // Name input
                FancyTextField(
                  controller: nameController,
                  hintText: "Enter your name",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Email input
                FancyTextField(
                  controller: emailController,
                  hintText: "Enter your email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password input
                FancyTextField(
                  controller: passwordController,
                  hintText: "Enter your password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Confirm password input
                FancyTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm your password",
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // Login button
                BasicButton(onTap: register, text: "Register"),

                const SizedBox(height: 25),

                // Login text
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already a member? ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),

                      TextSpan(
                        text: "Login now!",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            widget.togglePages!();
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
