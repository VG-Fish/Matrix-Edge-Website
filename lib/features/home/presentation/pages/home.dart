import 'package:flutter/material.dart';
import 'package:matrix_edge_website/features/home/presentation/components/homepage_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),

      drawer: HomepageDrawer(),
    );
  }
}
