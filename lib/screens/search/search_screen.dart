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

  void _search() {
    context.read<MovieProvider>().searchMovies(_searchController.text);
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
      appBar: AppBar(title: const Text('Search Movies')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search for a movie...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildResults(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(MovieProvider provider) {
    if (provider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchErrorMessage != null) {
      return Center(child: Text(provider.searchErrorMessage!));
    }

    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text('Search for a movie'));
    }

    if (provider.searchResults.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    return GridView.builder(
      itemCount: provider.searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        return MovieCard(movie: provider.searchResults[index]);
      },
    );
  }
}
