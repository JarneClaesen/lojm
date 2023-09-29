import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/auth/login_or_register.dart';
import 'package:orchestra_app/pages/profile_page.dart';
import 'package:orchestra_app/pages/scores_page.dart';

class AuthenticationMethods {
  final BuildContext context;

  AuthenticationMethods(this.context);

  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void goToScoresPage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoresPage()));
  }
}
