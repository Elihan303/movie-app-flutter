// ignore_for_file: prefer_const_constructors
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/forget_password.dart';
import 'package:my_movie_app/components/my_button.dart';
import 'package:my_movie_app/components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controladores
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      errors(e.code);
    }
  }

  void errors(String code) {
    var text = '';

    switch (code) {
      case 'invalid-email':
        text = 'Correo erroneo';
        break;
      case 'wrong-password':
        text = 'Contraseña erroneo';
        break;
      case 'invalid-credential':
        text = 'Credenciales invalidas';
        break;

      default:
        text = 'Ha ocurrido un error';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
              child: Text(
            text,
            style: TextStyle(color: Colors.white),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: SafeArea(
        child: SingleChildScrollView(
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
              ),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'No tiene cuenta?',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text('Registrate ya!',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold)),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
