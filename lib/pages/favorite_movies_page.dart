// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteMoviesPage extends StatelessWidget {
  FavoriteMoviesPage({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis películas favoritas'),
      ),
      body: user == null
          ? Center(
              child: Text('Por favor, inicia sesión para ver tus favoritos'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tienes películas favoritas.'));
                } else {
                  final favorites = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final favorite =
                          favorites[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        child: ListTile(
                          leading: Image.network(
                            'https://image.tmdb.org/t/p/w500${favorite['posterPath']}',
                          ),
                          title: Text(favorite['title']),
                          subtitle: Text(
                              'Fecha de salida: ${favorite['releaseDate']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('favorites')
                                  .doc(favorites[index].id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
