import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/components/event_post.dart';

import '../helper/helper_methods.dart';
import 'event_form_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String? userInstrument;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserInstrument();
  }

  _fetchUserInstrument() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("Users").doc(currentUser!.email).get();
      if(userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userInstrument = data['Instrument'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy("eventStartTime", descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active && snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final event = snapshot.data!.docs[index];
                var eventData = event.data() as Map<String, dynamic>;
                bool isUserInstrumentInSchedule = false;

                // Check if user's instrument is in the event schedule
                for (var schedule in (eventData['schedules'] ?? [])) {
                  if ((schedule['instruments'] as List).contains(userInstrument)) {
                    isUserInstrumentInSchedule = true;
                    break;
                  }
                }

                return EventPost(
                  title: eventData['title'],
                  startTime: formatTime(eventData['eventStartTime']),
                  endTime: formatTime(eventData['eventEndTime']),
                  location: eventData['location'],
                  eventData: eventData,
                  dotColor: isUserInstrumentInSchedule ? Colors.green : Colors.red, // Add dotColor attribute to EventPost constructor
                );
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventFormPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
