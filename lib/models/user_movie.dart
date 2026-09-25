class UserMovie {
  final String userId;
  final int movieId;
  final bool isFavorite;
  final bool isWatched;
  final bool isWatching;
  final bool isWantToWatch;

  UserMovie({
    required this.userId,
    required this.movieId,
    this.isFavorite = false,
    this.isWatched = false,
    this.isWatching = false,
    this.isWantToWatch = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'isFavorite': isFavorite,
      'isWatched': isWatched,
      'isWatching': isWatching,
      'isWantToWatch': isWantToWatch,
    };
  }

  factory UserMovie.fromMap(Map<String, dynamic> map) {
    return UserMovie(
      userId: map['userId'] ?? '',
      movieId: map['movieId'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      isWatched: map['isWatched'] ?? false,
      isWatching: map['isWatching'] ?? false,
      isWantToWatch: map['isWantToWatch'] ?? false,
    );
  }

  UserMovie copyWith({
    bool? isFavorite,
    bool? isWatched,
    bool? isWatching,
    bool? isWantToWatch,
  }) {
    return UserMovie(
      userId: userId,
      movieId: movieId,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatched: isWatched ?? this.isWatched,
      isWatching: isWatching ?? this.isWatching,
      isWantToWatch: isWantToWatch ?? this.isWantToWatch,
    );
  }
}
