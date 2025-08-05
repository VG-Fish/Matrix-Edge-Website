import 'package:flutter/material.dart';
import 'package:matrix_edge_website/features/auth/presentation/pages/login.dart';
import 'package:matrix_edge_website/features/auth/presentation/pages/register.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  void togglePage() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginPage(togglePages: togglePage);
    } else {
      return RegisterPage(togglePages: togglePage);
    }
  }
}
