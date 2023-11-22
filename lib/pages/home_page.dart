import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:orchestra_app/components/drawer.dart';
import 'package:orchestra_app/components/message_post.dart';
import 'package:orchestra_app/components/text_field.dart';
import 'package:orchestra_app/pages/profile_page.dart';
import 'package:orchestra_app/pages/scores_page.dart';

import '../components/message_text_field.dart';
import '../helper/helper_methods.dart';
import '../helper/authentication_methods.dart';
import 'calendar_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helper/notification_methods.dart';

// todo: make it so user doesn't get notifications when the app is open

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final textController = TextEditingController();

  // user
  final currentUser = FirebaseAuth.instance.currentUser;

  late AuthenticationMethods authenticationMethods;
  bool isAdmin = false;

  void postMessage() async {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      try {
        Map<String, String> userDetails = await fetchUserDetails(currentUser?.email ?? '');

        // store in firebase
        await FirebaseFirestore.instance.collection("messages").add({
          'UserEmail': currentUser?.email,
          'FirstName': userDetails['firstName'],
          'LastName': userDetails['lastName'],
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
        });

        // Send notification using OneSignal
        String fullName = "${userDetails['firstName']} ${userDetails['lastName']}";
        var playerId = OneSignal.User.pushSubscription.id;
        print("playerId: $playerId");
        await sendOneSignalNotification(fullName, textController.text, playerId!);

        textController.clear();  // Clear the text field after a successful post.
      } catch (e) {
        print("Error writing to Firestore: $e");
      }
    }

      // refresh the page
      textController.clear();
  }

  @override
  void initState() {
    super.initState();
    authenticationMethods = AuthenticationMethods(context);
    fetchAdminStatus();
  }

  Future<Map<String, String>> fetchUserDetails(String email) async {
    Map<String, String> userDetails = {'firstName': '', 'lastName': ''};

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(email).get();
      if (userDoc.exists) {
        userDetails['firstName'] = userDoc['FirstName'] ?? '';
        userDetails['lastName'] = userDoc['LastName'] ?? '';
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }

    return userDetails;
  }

  void fetchAdminStatus() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("Users").doc(currentUser!.email).get();
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          isAdmin = data['IsAdmin'] ?? false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('Lojm'),
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              indicatorColor: Theme.of(context).colorScheme.onSurface,
              dividerColor: Theme.of(context).colorScheme.tertiary,
              tabs: [
                Tab(text: 'Home'),
                Tab(text: 'Calendar'),
              ],
            ),
          ),
          drawer: MyDrawer(
            onProfileTap: authenticationMethods.goToProfilePage,
            onSignOut: authenticationMethods.logout,
            onScoresTap: authenticationMethods.goToScoresPage,
          ),
          body: TabBarView(
            children: [
              Center(
              child: Column(
                children: [
                  // the wall
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('messages').orderBy("TimeStamp", descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.active && snapshot.data != null) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                //get the message
                                final message = snapshot.data!.docs[index];
                                return messagePost(
                                  firstName: message['FirstName'],
                                  lastName: message['LastName'],
                                  message: message['Message'],
                                  user: message['UserEmail'],
                                  postId: message.id,
                                  likes: List<String>.from(message['Likes'] ?? []),
                                  date: formatDate(message['TimeStamp']),
                                  time: formatTime(message['TimeStamp'])
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
                  isAdmin
                    ? Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          // Make sure children align to the end (bottom)
                          children: [
                            Expanded(
                              child: ConstrainedBox( // Constrain the height
                                constraints: BoxConstraints(
                                  maxHeight: 150, // This can be adjusted to your preference
                                ),
                                child: SingleChildScrollView( // Make sure the TextField is scrollable when content overflows
                                  child: MyMessageTextField(
                                    controller: textController,
                                    hintText: 'Post a message',
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              // Adjust the bottom padding as needed
                              child: IconButton(
                                onPressed: postMessage,
                                icon: const Icon(Icons.send),
                              ),
                            ),
                          ],
                        ),
                      )
                  : const SizedBox.shrink(),


                  // logged in as
                  //Text('Logged in as: ' + (currentUser?.email ?? "Unknown"), style: const TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                ],
              ),
            ),
              CalendarPage(),
            ],
          )
      ),
    );
  }
}