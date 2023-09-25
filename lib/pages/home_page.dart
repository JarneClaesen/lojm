import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/components/drawer.dart';
import 'package:orchestra_app/components/message_post.dart';
import 'package:orchestra_app/components/text_field.dart';
import 'package:orchestra_app/pages/profile_page.dart';
import 'package:orchestra_app/pages/scores_page.dart';

import '../helper/helper_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final textController = TextEditingController();

  // user
  final currentUser = FirebaseAuth.instance.currentUser;

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() async {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      try {
        // store in firebase
        await FirebaseFirestore.instance.collection("messages").add({
          'UserEmail': currentUser?.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
        });
        textController.clear();  // Clear the text field after a successful post.
      } catch (e) {
        print("Error writing to Firestore: $e");
      }
    }

    setState(() {
      // refresh the page
      textController.clear();
    });
  }

  // navigate to profile page
  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void goToScoresPage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoresPage()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Orchestra App'),
        ),
        drawer: MyDrawer(
          onProfileTap: goToProfilePage,
          onSignOut: logout,
          onScoresTap: goToScoresPage,
        ),
        body: Center(
          child: Column(
            children: [
              // the wall
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('messages').orderBy("TimeStamp", descending: false).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active && snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            //get the message
                            final message = snapshot.data!.docs[index];
                            return messagePost(
                              message: message['Message'],
                              user: message['UserEmail'],
                              postId: message.id,
                              likes: List<String>.from(message['Likes'] ?? []),
                              time: formatDate(message['TimeStamp'])
                            );// Ensure MessagePost widget accepts these parameters
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ' + snapshot.error.toString()),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
              ),

              // post message
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                    children: [
                      Expanded(
                        child: MyTextField(
                          controller: textController,
                          hintText: 'Post a message',
                        ),
                      ),
                      IconButton(
                        onPressed: postMessage,
                        icon: const Icon(Icons.send),
                      ),
                    ]
                ),
              ),

              // logged in as
              Text('Logged in as: ' + (currentUser?.email ?? "Unknown"), style: const TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
            ],
          ),
        )
    );
  }
}