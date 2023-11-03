import 'Package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orchestra_app/components/button.dart';
import 'package:orchestra_app/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool _isLoading = false;

  // sign user in
  void signIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing the dialog by tapping outside of it
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text
      );
      // If the sign-in was successful
      if (context.mounted) {
        Navigator.pop(context); // Dismiss the loading dialog
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      displayMessage(e.code);
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false; // Stop loading on both success and failure
        });
      }
    }
  }

  // display a dialog message
  void displayMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDarkMode
        ? 'assets/images/lojmLogoRemovebgWhite.png'
        : 'assets/images/lojmLogoRemovebg.png';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //logo
                Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                    height: 200,
                    width: 200
                ),

                const SizedBox(height: 50),

                // welcome back message
                Text(
                  'Welcome Back!',
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

                const SizedBox(height: 25),

                //signin button
                MyButton(onTap: signIn, text: 'Sign in'),

                const SizedBox(height: 10),

                // go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?',
                        style: TextStyle(
                            color: Colors.grey[500]
                        ),
                    ),
                    TextButton(
                      onPressed: widget.onTap,
                      child: const Text('Register'),
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