// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_movie_app/models/rated_movie.dart';

class RatedMoviesPage extends StatefulWidget {
  const RatedMoviesPage({super.key});

  @override
  _RatedMoviesPageState createState() => _RatedMoviesPageState();
}

class _RatedMoviesPageState extends State<RatedMoviesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<RatedMovie>> _ratedMovies;

  @override
  void initState() {
    super.initState();
    _ratedMovies = _fetchRatedMovies();
  }

  Future<List<RatedMovie>> _fetchRatedMovies() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final ratingDocs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movieRatings')
          .get();

      return ratingDocs.docs
          .map((doc) => RatedMovie.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching rated movies: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Películas Calificadas'),
      ),
      body: FutureBuilder<List<RatedMovie>>(
        future: _ratedMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No se encontraron películas calificadas.'));
          } else {
            final movies = snapshot.data!;
            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: movie.posterPath.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.movie),
                  title: Text(movie.title),
                  subtitle: Text(
                      'Calificación: ${movie.rating.toStringAsFixed(1)} / 5'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
