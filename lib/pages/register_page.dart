import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final comfirmPasswordTextController = TextEditingController();

  // sign user up
  void signUp() async {

    if (passwordTextController.text != comfirmPasswordTextController.text) {
      displayMessage('Passwords do not match');
      return;
    }

    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // create user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text
      );

      // after creating user, create new document in could firestore called users
      FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.uid).set({
        'Email': emailTextController.text,
        'FirstName': '',
        'LastName': '',
        'Instrument': '',
        'Bio': 'Empty bio',
        'ProfilePicture': '',
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


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
                MyTextField(controller: comfirmPasswordTextController, hintText: 'Comfirm Password', obscureText: true),

                const SizedBox(height: 25),

                //signin button
                MyButton(onTap: signUp, text: 'Sign Up'),

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
                      onPressed: widget.onTap,
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