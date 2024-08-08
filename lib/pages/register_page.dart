// ignore_for_file: prefer_const_constructors
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_movie_app/components/my_button.dart';
import 'package:my_movie_app/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //controladores
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign up
  void signUpUser() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    try {
      if (confirmPasswordController.text == passwordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: confirmPasswordController.text,
        );
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        errors('password-no-match');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      errors(e.code);
    }
  }

  void errors(String code) {
    var text = '';

    switch (code) {
      case 'weak-password':
        text = 'Contraseña debil';
        break;
      case 'email-already-in-use':
        text = 'Intente con otro correo';
        break;
      case 'password-no-match':
        text = 'La contraseña no coincide';
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
                Icons.app_registration_rounded,
                color: Colors.deepPurpleAccent,
                size: 100.0,
              ),

              SizedBox(height: 50),

              Text(
                '¡Registrate ya!',
                style: TextStyle(fontSize: 32.0),
              ),

              SizedBox(height: 50),

              //text field email
              MyTextField(
                controller: emailController,
                hintText: 'Correo',
                obscureText: false,
              ),
              SizedBox(height: 10),

              //text field contraseña
              MyTextField(
                controller: passwordController,
                hintText: "Contraseña",
                obscureText: true,
              ),
              SizedBox(height: 10),
              //text field contraseña
              MyTextField(
                controller: confirmPasswordController,
                hintText: "Confirma su contraseña",
                obscureText: true,
              ),

              SizedBox(height: 10),

              SizedBox(height: 30),
              //Boton de inicio de sesion
              MyButton(
                title: 'Crear cuenta',
                onTap: signUpUser,
              ),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Ya tienes cuenta?',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text('Inicia sesion!',
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
