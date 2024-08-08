// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:my_movie_app/pages/favorite_movies_page.dart';
import 'package:my_movie_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavBar extends StatelessWidget {
  NavBar({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Name"),
            accountEmail: Text(user.email!),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(child: Icon(Icons.person_outline)
                  // Image.network(
                  //   'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  //   fit: BoxFit.cover,
                  //   width: 90,
                  //   height: 90,
                  // ),
                  ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favoritos'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteMoviesPage(),
                ),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Politicas'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            title: Text('Cerrar sección'),
            leading: Icon(Icons.exit_to_app),
            onTap: signUserOut,
          ),
        ],
      ),
    );
  }
}
