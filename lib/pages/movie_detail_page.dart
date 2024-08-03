// // ignore_for_file: prefer_const_constructors
// import 'package:flutter/material.dart';
// import '../models/movies.dart';

// class MovieDetailPage extends StatelessWidget {
//   final Movie movie;

//   const MovieDetailPage({super.key, required this.movie});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(movie.title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: Image.network(
//                 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(movie.title,
//                 style: Theme.of(context).textTheme.headlineMedium //headline5,
//                 ),
//             SizedBox(height: 8.0),
//             Text(
//               movie.overview,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/actors.dart';
import '../models/movies.dart';
// ignore_for_file: prefer_const_constructors

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  MovieDetailPage({super.key, required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Actor>> _cast;

  @override
  void initState() {
    super.initState();
    _cast = _fetchCast(widget.movie.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
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
            SizedBox(height: 16.0),
            Text(
              widget.movie.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Release Date: ${widget.movie.releaseDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              widget.movie.overview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16.0),
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
                      SizedBox(height: 8.0),
                      ...cast.map((actor) => ListTile(
                            leading: actor.profilePath != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500${actor.profilePath}',
                                    ),
                                  )
                                : CircleAvatar(child: Icon(Icons.person)),
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
