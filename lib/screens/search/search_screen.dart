import 'dart:async';

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

  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<MovieProvider>().searchMovies(value);
    });

    setState(() {});
  }

  void _search() {
    _debounce?.cancel();
    context.read<MovieProvider>().searchMovies(_searchController.text);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<MovieProvider>().clearSearch();
    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Search Movies')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search for a movie...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 12),
              Text(
                'Something went wrong.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a movie',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Find your next movie to watch.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (provider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_filter_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'No movies found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different title.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
      itemCount: provider.searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 325,
      ),
      itemBuilder: (context, index) {
        return MovieCard(movie: provider.searchResults[index]);
      },
    );
  }
}
