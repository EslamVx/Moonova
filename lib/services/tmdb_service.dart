import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
}
