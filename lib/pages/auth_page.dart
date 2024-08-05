// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:my_movie_app/pages/home_page.dart';
import 'package:my_movie_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          //usuario login in
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
