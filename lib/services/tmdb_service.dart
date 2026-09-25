import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_response.dart';

class TmdbService {
  final String _baseUrl = 'https://api.themoviedb.org/3';

  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}',
    'accept': 'application/json',
  };

  Future<MovieResponse> getPopularMovies() async {
    final url = Uri.parse('$_baseUrl/movie/popular');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MovieResponse.fromJson(data);
    }

    throw Exception('Failed to load popular movies: ${response.statusCode}');
  }

  Future<MovieResponse> getTrendingMovies() async {
    final url = Uri.parse('$_baseUrl/trending/movie/week');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MovieResponse.fromJson(data);
    }

    throw Exception('Failed to load trending movies: ${response.statusCode}');
  }

  Future<MovieResponse> searchMovies(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search/movie?query=${Uri.encodeQueryComponent(query)}',
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MovieResponse.fromJson(data);
    }

    throw Exception('Failed to search movies: ${response.statusCode}');
  }

  Future<List<Genre>> getMovieGenres() async {
    final url = Uri.parse('$_baseUrl/genre/movie/list');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['genres'] as List)
          .map((genre) => Genre.fromJson(genre))
          .toList();
    }

    throw Exception('Failed to load movie genres: ${response.statusCode}');
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final url = Uri.parse('$_baseUrl/movie/$movieId');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Movie.fromJson(data);
    }

    throw Exception('Failed to load movie details: ${response.statusCode}');
  }
}
