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
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Actor>> _cast;
  bool _isFavorite = false;
  double _userRating = 0.0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _cast = _fetchCast(widget.movie.id);
    _checkIfFavorite();
    _getUserRating();
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

  Future<void> _getUserRating() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movieRatings')
          .doc(widget.movie.id.toString())
          .get();
      if (doc.exists) {
        setState(() {
          _userRating = doc['rating']?.toDouble() ?? 0.0;
        });
      }
    }
  }

  Future<void> _submitRating(double rating) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference ratingRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movieRatings')
          .doc(widget.movie.id.toString());

      // Save the rating
      await ratingRef.set({
        'rating': rating,
        'posterPath': widget.movie.posterPath,
        'title': widget.movie.title,
        'id': widget.movie.id
      });

      // Save the movie details with rating
      DocumentReference movieRef =
          _firestore.collection('movies').doc(widget.movie.id.toString());

      await movieRef.set({
        'posterPath': widget.movie.posterPath,
        'title': widget.movie.title,
        'id': widget.movie.id,
        'rating': rating,
      });

      setState(() {
        _userRating = rating;
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
              'Fecha de salida: ${widget.movie.releaseDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.movie.overview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Califica esta pelicula:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            StarRating(
              rating: _userRating,
              onRatingChanged: _submitRating,
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
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cast.length,
                    itemBuilder: (context, index) {
                      final actor = cast[index];
                      return ListTile(
                        leading: actor.profilePath != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://image.tmdb.org/t/p/w500${actor.profilePath}',
                                ),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(actor.name),
                        subtitle: Text('es ${actor.character}'),
                      );
                    },
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

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => onRatingChanged(starIndex.toDouble()),
        );
      }),
    );
  }
}
