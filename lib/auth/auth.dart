import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/auth/login_or_register.dart';

import '../pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print("Auth Stream data: ${snapshot.data}");
          print("Auth Stream error: ${snapshot.error}");
          if (snapshot.hasData) {
            return const HomePage();
          }
          else {
            return const LoginOrRegister();
          }
    },
      )
    );
  }
}