// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'components/forget_password.dart';
import 'package:my_movie_app/components/my_button.dart';
import 'package:my_movie_app/components/my_textfield.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controladores
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[350],
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50),

                //logo app
                Icon(
                  Icons.movie,
                  color: Colors.deepPurpleAccent,
                  size: 100.0,
                ),

                SizedBox(height: 50),

                Text(
                  '¡Bienvenido!',
                  style: TextStyle(fontSize: 32.0),
                ),

                SizedBox(height: 50),

                //text field email
                MyTextField(
                  controller: emailController,
                  hintText: 'Escriba su correo...',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                //text field contraseña
                MyTextField(
                  controller: passwordController,
                  hintText: "Escriba su contraseña",
                  obscureText: true,
                ),

                SizedBox(height: 10),

                // olvidaste tu contraseña
                ForgetPassword(),
                SizedBox(height: 30),
                //Boton de inicio de sesion
                MyButton(
                  title: 'Inicia sesion',
                  onTap: signUserIn,
                )
              ],
            ),
          ),
        ));
  }
}
