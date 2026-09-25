import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/movie_provider.dart';
import '../../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _searchMovies() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    context.read<MovieProvider>().searchMovies(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchMovies(),
          decoration: const InputDecoration(
            hintText: 'Search for a movie...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _searchMovies,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(MovieProvider provider) {
    if (provider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchErrorMessage != null) {
      return Center(child: Text(provider.searchErrorMessage!));
    }

    if (provider.searchResults.isEmpty) {
      return const Center(child: Text('Search for a movie'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 150 / 290,
      ),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: provider.searchResults[index]);
      },
    );
  }
}
