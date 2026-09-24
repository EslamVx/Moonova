import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/movie_provider.dart';
import '../../widgets/movie_horizontal_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();

      if (provider.popularMovies.isEmpty) {
        provider.loadPopularMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('HOME SCREEN TEST')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(MovieProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    if (provider.popularMovies.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Popular Movies',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          MovieHorizontalList(movies: provider.popularMovies),
        ],
      ),
    );
  }
}
