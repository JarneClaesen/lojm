import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                //logo
                const Icon(Icons.lock, size: 100),

                const SizedBox(height: 50),

                // welcome back message
                Text(
                  "Let's get started",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                // email textfield
                MyTextField(controller: emailTextController, hintText: 'Email', obscureText: false),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(controller: passwordTextController, hintText: 'Password', obscureText: true),

                const SizedBox(height: 10),

                // comfirm password textfield
                MyTextField(controller: passwordTextController, hintText: 'Comfirm Password', obscureText: true),

                const SizedBox(height: 25),

                //signin button
                MyButton(onTap: () {}, text: 'Sign Up'),

                const SizedBox(height: 10),

                // go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                      style: TextStyle(
                          color: Colors.grey[500]
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Login'),
                    ),],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}