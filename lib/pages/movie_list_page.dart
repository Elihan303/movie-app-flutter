// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/movies.dart';
import 'movie_detail_page.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Movie>> _nowPlayingMovies;
  late Future<List<Movie>> _upcomingMovies;

  @override
  void initState() {
    super.initState();
    _nowPlayingMovies = _fetchNowPlayingMovies();
    _upcomingMovies = _fetchUpcomingMovies();
  }

  Future<List<Movie>> _fetchNowPlayingMovies() async {
    try {
      final moviesResponse = await _apiService.getMovies('/now_playing');
      MoviesResponse moviesResponseData =
          MoviesResponse.fromJson(moviesResponse.data);
      return moviesResponseData.results;
    } catch (e) {
      debugPrint('Error fetching now playing movies: $e');
      return [];
    }
  }

  Future<List<Movie>> _fetchUpcomingMovies() async {
    try {
      final moviesResponse = await _apiService.getMovies('/upcoming');
      MoviesResponse moviesResponseData =
          MoviesResponse.fromJson(moviesResponse.data);
      return moviesResponseData.results;
    } catch (e) {
      debugPrint('Error fetching upcoming movies: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peliculas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _nowPlayingMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No now playing movies found'));
                } else {
                  final movies = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Now Playing',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      SizedBox(
                        height: 200, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies?.length,
                          itemBuilder: (context, index) {
                            final movie = movies?[index];

                            return GestureDetector(
                              onTap: () {
                                print(movie?.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailPage(movie: movie!),
                                  ),
                                );
                              },
                              child: Container(
                                width: 120, // Adjust width as needed
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Container(
                                      width: 120,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              'https://image.tmdb.org/t/p/w500${movie?.posterPath}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                                    Text(
                                      movie?.title ?? 'No Title',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _upcomingMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No upcoming movies found'));
                } else {
                  final movies = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Upcoming Movies',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      SizedBox(
                        height: 200, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies?.length,
                          itemBuilder: (context, index) {
                            final movie = movies?[index];
                            return Container(
                              width: 120,
                              margin: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Container(
                                    width: 120,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            'https://image.tmdb.org/t/p/w500${movie?.posterPath}'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                                  Text(
                                    movie?.title ?? 'No Title',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
