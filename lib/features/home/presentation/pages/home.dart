import 'package:flutter/material.dart';
import 'package:matrix_edge_website/features/home/presentation/components/homepage_drawer.dart';
import 'package:matrix_edge_website/features/post/presentation/pages/upload_posts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadPostsPage()),
            ),
          ),
        ],
      ),

      drawer: HomepageDrawer(),
    );
  }
}
