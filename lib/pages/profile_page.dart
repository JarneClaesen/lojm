import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser;

  // edit field
  Future<void> editField(String field) async {
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50.0),

          // Profile picture
          Icon(
            Icons.person,
            size: 72,
          ),

          const SizedBox(height: 10.0),

          // User email
          Text(
            currentUser?.email ?? "No email",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 50.0),

          // user details
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text("My Details",
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[600],
              ),
            ),
          ),

          // username
          MyTextBox(
              text: 'Jarne',
              sectionName: 'username',
              onPressed: () => editField('username'),
          ),

          // bio
          MyTextBox(
              text: 'empty bio',
              sectionName: 'bio',
              onPressed: () => editField('bio'),
          ),

          const SizedBox(height: 50.0),

          // user posts
          MyTextBox(
              text: 'empty posts',
              sectionName: 'posts',
              onPressed: () => editField('messages'),
          )
        ],
      ),
    );
  }
}