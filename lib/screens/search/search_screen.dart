import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/movie_card_skeleton.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    setState(() {});

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<MovieProvider>().searchMovies(value);
    });
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

    _searchFocusNode.requestFocus();
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Movies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _buildSearchField(theme),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _dismissKeyboard,
              behavior: HitTestBehavior.translucent,
              child: _buildResults(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    final hasText = _searchController.text.trim().isNotEmpty;

    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.words,
      onChanged: _onSearchChanged,
      onSubmitted: (_) => _search(),
      decoration: InputDecoration(
        hintText: 'Search movies...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasText
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildResults(MovieProvider provider) {
    final query = _searchController.text.trim();

    if (provider.isSearching) {
      return _buildLoading();
    }

    if (provider.searchErrorMessage != null) {
      return ErrorState(
        message: 'We could not search for movies.\nPlease try again.',
        onRetry: _search,
      );
    }

    if (query.isEmpty) {
      return const EmptyState(
        title: 'Search for a movie',
        message: 'Find your next movie to watch.',
        icon: Icons.search_rounded,
      );
    }

    if (provider.searchResults.isEmpty) {
      return const EmptyState(
        title: 'No movies found',
        message: 'Try searching with a different title.',
        icon: Icons.movie_filter_outlined,
      );
    }

    return _buildMovieGrid(provider);
  }

  Widget _buildMovieGrid(MovieProvider provider) {
    return GridView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: provider.searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 325,
      ),
      itemBuilder: (context, index) {
        final movie = provider.searchResults[index];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.94, end: 1),
          duration: Duration(milliseconds: 250 + (index * 40)),
          curve: Curves.easeOutCubic,
          child: MovieCard(movie: movie),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 325,
      ),
      itemBuilder: (context, index) {
        return const MovieCardSkeleton();
      },
    );
  }
}
