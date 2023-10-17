import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:orchestra_app/components/drawer.dart';
import 'package:orchestra_app/components/message_post.dart';
import 'package:orchestra_app/components/text_field.dart';
import 'package:orchestra_app/pages/profile_page.dart';
import 'package:orchestra_app/pages/scores_page.dart';

import '../helper/helper_methods.dart';
import '../helper/authentication_methods.dart';
import 'calendar_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    setState(() {
      // refresh the page
      textController.clear();
    });
  }

  Future<String> fetchUserPlayerId(String userEmail) async {
    // Retrieve the player_id for the given userEmail from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
    return (userDoc.data() as Map<String, dynamic>)?['player_id'] ?? '';

  }

  Future<void> sendOneSignalNotification(String title, String messageContent, String senderPlayerId) async {
    const String apiUrl = 'https://onesignal.com/api/v1/notifications';
    const String appId = 'c060575a-62b7-4692-a983-517f9ef27627'; // Replace with your OneSignal App ID
    const String apiKey = 'NjFkMmMyZmQtODY1Ni00NDkwLWIxMTItOWY4YzczNDQzYmEw'; // Replace with your OneSignal REST API Key
    const String oneSignalEndpoint = "https://onesignal.com/api/v1/players?app_id=$appId";

    // Fetch all player IDs from your database
    List<String> allPlayerIds = await fetchAllPlayerIdsFromOneSignal();

    // Remove the sender's player ID from the list
    allPlayerIds.remove(senderPlayerId);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $apiKey',
        },
        body: json.encode({
          'app_id': appId,
          'include_player_ids': allPlayerIds,  // Use the filtered list
          'headings': {'en': title},
          'contents': {'en': messageContent},
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending OneSignal notification: $e');
    }
  }

  Future<List<String>> fetchAllPlayerIdsFromOneSignal() async {
    const String appId = 'c060575a-62b7-4692-a983-517f9ef27627';
    const String apiKey = 'NjFkMmMyZmQtODY1Ni00NDkwLWIxMTItOWY4YzczNDQzYmEw';
    const String oneSignalEndpoint = "https://onesignal.com/api/v1/players?app_id=$appId";
    List<String> playerIds = [];

    int offset = 0;
    int limit = 300; // You can adjust this value as needed

    while (true) {
      final response = await http.get(
        Uri.parse("$oneSignalEndpoint&limit=$limit&offset=$offset"),
        headers: {
          "Authorization": "Basic $apiKey",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['players'] != null) {
          for (var player in responseBody['players']) {
            playerIds.add(player['id']);
          }

          if (responseBody['players'].length < limit) {
            break; // End the loop if we've fetched all players
          } else {
            offset += limit; // Increase the offset for the next batch
          }
        } else {
          break; // End the loop if there are no players
        }
      } else {
        throw Exception("Failed to fetch players from OneSignal: ${response.body}");
      }
    }

    return playerIds;
  }

  @override
  void initState() {
    super.initState();
    authenticationMethods = AuthenticationMethods(context);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('Orchestra App'),
            bottom: const TabBar(
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
                        stream: FirebaseFirestore.instance.collection('messages').orderBy("TimeStamp", descending: false).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.active && snapshot.data != null) {
                            return ListView.builder(
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
            ),
              CalendarPage(),
            ],
          )
      ),
    );
  }
}