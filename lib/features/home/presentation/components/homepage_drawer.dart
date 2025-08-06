import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:matrix_edge_website/features/home/presentation/components/homepage_drawer_tile.dart';
import 'package:matrix_edge_website/features/profile/presentation/pages/profile.dart';
import 'package:matrix_edge_website/features/search/presentation/pages/search_page.dart';
import 'package:matrix_edge_website/features/settings/pages/settings_page.dart';

class HomepageDrawer extends StatelessWidget {
  const HomepageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Person icon
              Icon(Icons.person, size: 80, color: theme.colorScheme.primary),

              Divider(color: theme.colorScheme.secondary),

              // Home tile
              HomepageDrawerTile(title: "Home", icon: Icons.home, onTap: () {}),

              // Profile tile
              HomepageDrawerTile(
                title: "Profile",
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).pop();

                  final user = context.read<AuthCubit>().currentUser;
                  if (user == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: user.uid),
                    ),
                  );
                },
              ),

              // Search tile
              HomepageDrawerTile(
                title: "Search",
                icon: Icons.search,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                ),
              ),

              // Settings tile
              HomepageDrawerTile(
                title: "Settings",
                icon: Icons.settings,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                ),
              ),

              const Spacer(),

              // Logout tile
              HomepageDrawerTile(
                title: "Logout",
                icon: Icons.logout,
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
