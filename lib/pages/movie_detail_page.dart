import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/actors.dart';
import '../models/movies.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  // ignore: library_private_types_in_public_api
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Actor>> _cast;
  bool _isFavorite = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _cast = _fetchCast(widget.movie.id);
    _checkIfFavorite();
  }

  Future<List<Actor>> _fetchCast(int movieId) async {
    try {
      final response = await _apiService.getMovies('/$movieId/credits');
      final data = response.data;

      final cast = data['cast'] as List;

      return cast.map((actorJson) => Actor.fromJson(actorJson)).toList();
    } catch (e) {
      debugPrint('Error fetching movie cast: $e');
      return [];
    }
  }

  Future<void> _checkIfFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.movie.id.toString())
          .get();
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference favoriteRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.movie.id.toString());

      if (_isFavorite) {
        await favoriteRef.delete();
      } else {
        await favoriteRef.set({
          'movieId': widget.movie.id,
          'title': widget.movie.title,
          'posterPath': widget.movie.posterPath,
          'releaseDate': widget.movie.releaseDate,
          'overview': widget.movie.overview,
        });
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.movie.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Release Date: ${widget.movie.releaseDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.movie.overview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<List<Actor>>(
              future: _cast,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No cast information available.'));
                } else {
                  final cast = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actores:',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8.0),
                      ...cast.map((actor) => ListTile(
                            leading: actor.profilePath != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500${actor.profilePath}',
                                    ),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(actor.name),
                            subtitle: Text('as ${actor.character}'),
                          )),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
