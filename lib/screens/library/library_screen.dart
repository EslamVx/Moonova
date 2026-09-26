import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/movie_list_provider.dart';
import 'library_movie_list_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieListProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLibraryCard(
            context,
            title: 'Favorites',
            icon: Icons.favorite_rounded,
            count: provider.favorites.length,
            color: Colors.red,
            type: LibraryType.favorite,
          ),
          const SizedBox(height: 16),
          _buildLibraryCard(
            context,
            title: 'Watched',
            icon: Icons.visibility_rounded,
            count: provider.watched.length,
            color: Colors.green,
            type: LibraryType.watched,
          ),
          const SizedBox(height: 16),
          _buildLibraryCard(
            context,
            title: 'Watching',
            icon: Icons.play_circle_rounded,
            count: provider.watching.length,
            color: Colors.blue,
            type: LibraryType.watching,
          ),
          const SizedBox(height: 16),
          _buildLibraryCard(
            context,
            title: 'Want to Watch',
            icon: Icons.bookmark_rounded,
            count: provider.wantToWatch.length,
            color: Colors.orange,
            type: LibraryType.wantToWatch,
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int count,
    required Color color,
    required LibraryType type,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LibraryMovieListScreen(title: title, type: type),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$count movies', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

enum LibraryType { favorite, watched, watching, wantToWatch }
