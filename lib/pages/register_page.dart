import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../components/button.dart';
import '../components/dropdown.dart';
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
  final firstNameTextController = TextEditingController();
  final lastNameTextController = TextEditingController();

  List<String> instruments = ['Violin', 'Viola', 'Cello', 'Double Bass', 'Flute', 'Oboe', 'Clarinet', 'Bassoon', 'Trumpet', 'Trombone', 'Horn', 'Tuba', 'Percussion', 'Piano', 'Harp'];
  String? selectedInstrument;

  // sign user up
  void signUp() async {

    if (firstNameTextController.text.isEmpty ||
        lastNameTextController.text.isEmpty ||
        emailTextController.text.isEmpty ||
        passwordTextController.text.isEmpty ||
        comfirmPasswordTextController.text.isEmpty) { // 4. Check all fields are filled
      displayMessage('Please fill in all fields.');
      return;
    }

    if (selectedInstrument == null) {
      displayMessage('Please select an instrument.');
      return;
    }

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
      FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).set({
        'Username': emailTextController.text.split("@")[0],
        'FirstName': firstNameTextController.text,
        'LastName': lastNameTextController.text,
        'Instrument': selectedInstrument ?? 'Not selected',
        'Bio': 'Empty bio',
        'ProfilePicture': '',
        'IsAdmin': false,
      });

      // make new collection to store subscriptions_id's
      FirebaseFirestore.instance.collection("Subscriptions").doc(userCredential.user!.email).set({
        'subscription_id': OneSignal.User.pushSubscription.id,
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                //logo
                const Icon(Icons.lock, size: 50),

                const SizedBox(height: 20),

                // welcome back message
                Text(
                  "Let's get started",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // First name textfield
                MyTextField(controller: firstNameTextController, hintText: 'First Name', obscureText: false),

                const SizedBox(height: 10),

                // Last name textfield
                MyTextField(controller: lastNameTextController, hintText: 'Last Name', obscureText: false),

                const SizedBox(height: 10),

                // email textfield
                MyTextField(controller: emailTextController, hintText: 'Email', obscureText: false),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(controller: passwordTextController, hintText: 'Password', obscureText: true),

                const SizedBox(height: 10),

                // comfirm password textfield
                MyTextField(controller: comfirmPasswordTextController, hintText: 'Comfirm Password', obscureText: true),

                const SizedBox(height: 25),

                // instrument dropdown
                MyDropdown(
                  items: instruments,
                  selectedItem: selectedInstrument,
                  onChanged: (newValue) {
                    setState(() {
                      selectedInstrument = newValue;
                    });
                  },
                ),

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