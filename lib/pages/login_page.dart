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

    // Separate checks for email and password fields
    if (emailTextController.text.isEmpty) {
      displayErrorMessage('empty-email');
      return;
    }
    if (passwordTextController.text.isEmpty) {
      displayErrorMessage('empty-password');
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    bool isDialogShowing = true;

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
      // If the sign-in was successful && Only pop the dialog if we're still showing it
      if (isDialogShowing && context.mounted) {
        Navigator.pop(context); // Dismiss the loading dialog
        isDialogShowing = false;
      }
    } on FirebaseAuthException catch (e) {
      if (isDialogShowing && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogShowing = false;
      }
      displayErrorMessage(e.code); // Display custom error message
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false; // Stop loading on both success and failure
        });
      }
      // Ensure we clean up the dialog if it's still showing after all actions are complete
      if (isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void displayErrorMessage(String errorCode) {
    String errorMessage;
    switch (errorCode) {
      case 'empty-email':
        errorMessage = 'Please enter your email address.';
        break;
      case 'empty-password':
        errorMessage = 'Please enter your password.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is badly formatted.';
        break;
      case 'user-not-found':
        errorMessage = 'There is no user corresponding to the given email.';
        break;
      case 'wrong-password':
        errorMessage = 'The password is invalid for the given email.';
        break;
    // Add more cases as needed
      default:
        errorMessage = 'An unknown error occurred.';
    }
    // Display the error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }


  void sendPasswordResetEmail() async {
    if (emailTextController.text.isEmpty) {
      displayMessage("Please enter your email address to reset your password.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailTextController.text);
      displayMessage("Password reset link has been sent to your email address.");
    } on FirebaseAuthException catch (e) {
      displayMessage("Failed to send password reset email: ${e.message}");
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

                // forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: sendPasswordResetEmail,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}