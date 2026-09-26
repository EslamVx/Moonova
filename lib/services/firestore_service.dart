import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_movie.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserMovie(UserMovie userMovie) async {
    await _firestore
        .collection('users')
        .doc(userMovie.userId)
        .collection('movies')
        .doc(userMovie.movieId.toString())
        .set(userMovie.toMap());
  }

  Future<UserMovie?> getUserMovie({
    required String userId,
    required int movieId,
  }) async {
    final document = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movies')
        .doc(movieId.toString())
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return UserMovie.fromMap(document.data()!);
  }

  Future<List<UserMovie>> getUserMovies(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movies')
        .get();

    return snapshot.docs
        .map((document) => UserMovie.fromMap(document.data()))
        .toList();
  }

  Future<void> deleteUserMovie({
    required String userId,
    required int movieId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('movies')
        .doc(movieId.toString())
        .delete();
  }
}
