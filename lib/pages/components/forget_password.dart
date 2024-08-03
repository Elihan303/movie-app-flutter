import 'package:flutter/material.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '¿Olvidaste la contraseña?',
            style: TextStyle(
                color: Colors.deepPurple[700], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
