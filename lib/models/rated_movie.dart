import 'package:cloud_firestore/cloud_firestore.dart';

class RatedMovie {
  final int id;
  final String posterPath;
  final double rating;
  final String title;

  RatedMovie({
    required this.id,
    required this.posterPath,
    required this.rating,
    required this.title,
  });

  // Factory constructor to create a RatedMovie instance from Firestore document data
  factory RatedMovie.fromMap(Map<String, dynamic> data) {
    return RatedMovie(
      id: data['id'],
      posterPath: data['posterPath'],
      rating: (data['rating'] as num).toDouble(),
      title: data['title'],
    );
  }

  // Method to convert RatedMovie instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posterPath': posterPath,
      'rating': rating,
      'title': title,
    };
  }
}
