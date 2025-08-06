import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/search/presentation/cubits/search_cubit.dart';
import 'package:matrix_edge_website/features/search/presentation/cubits/search_states.dart';
import 'package:matrix_edge_website/responsive/constrained_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchTextController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChange() {
    final query = searchTextController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchTextController.addListener(onSearchChange);
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchTextController,
          decoration: InputDecoration(
            hintText: "Search users...",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),

      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, searchState) {
          if (searchState is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (searchState is SearchLoaded) {
            if (searchState.users.isEmpty) {
              return const Center(child: Text("No users found."));
            } else {
              return ListView.builder(
                itemCount: searchState.users.length,
                itemBuilder: (context, index) {
                  final user = searchState.users[index];
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CachedNetworkImage(
                              imageUrl: user!.profileImageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),

                            Text(
                              user.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          } else if (searchState is SearchError) {
            return Center(child: Text(searchState.message));
          } else {
            return const Center(child: Text("Start searching for users..."));
          }
        },
      ),
    );
  }
}
