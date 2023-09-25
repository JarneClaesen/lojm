import 'package:cloud_firestore/cloud_firestore.dart';
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
  // all users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Edit $field",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
            ),
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: [
            // cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            // save button
            TextButton(
              child: Text(
                  "Save",
                style: TextStyle(color: Colors.white)
              ),
              onPressed: () => Navigator.of(context).pop(newValue),
            ),
          ],
        )
    );

    if (newValue.trim().isNotEmpty) {
      // update field
      await usersCollection.doc(currentUser?.email).update({
        field: newValue,
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser?.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            // get data
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
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
                  text: userData['Username'] ?? '',
                  sectionName: 'Username',
                  onPressed: () => editField('Username'),
                ),

                // bio
                MyTextBox(
                  text: userData['Bio'] ?? 'Empty bio',
                  sectionName: 'Bio',
                  onPressed: () => editField('Bio'),
                ),

                const SizedBox(height: 50.0),

                // user posts
                MyTextBox(
                  text: userData['messages'] ?? 'No messages',
                  sectionName: 'posts',
                  onPressed: () => editField('messages'),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );

        },
      )
    );
  }
}