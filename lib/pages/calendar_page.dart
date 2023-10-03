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
      if (userDoc.exists && userDoc.data() != null) {
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
            final now = Timestamp.now();
            List<DocumentSnapshot> upcomingEvents = snapshot.data!.docs.where((event) => event.get("eventStartTime").compareTo(now) >= 0).toList();

            return ListView.builder(
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                final event = upcomingEvents[index];
                var eventData = event.data() as Map<String, dynamic>;
                bool isUserInstrumentInSchedule = false;
                DateTime eventDate = (eventData['eventStartTime'] as Timestamp).toDate();

                // Check if user's instrument is in the event schedule
                for (var schedule in (eventData['schedules'] ?? [])) {
                  // If it's a break, continue to the next iteration
                  if (schedule['piece'] == null && schedule['conductor'] == null) {
                    continue;
                  }

                  if ((schedule['instruments'] as List?)?.contains(userInstrument) == true) {
                    isUserInstrumentInSchedule = true;
                    break;
                  }
                }

                return EventPost(
                  date: eventDate,
                  title: eventData['title'],
                  startTime: formatTime(eventData['eventStartTime']),
                  endTime: formatTime(eventData['eventEndTime']),
                  location: eventData['location'],
                  eventData: eventData,
                  dotColor: (eventData['schedules'] as List?)?.isEmpty ?? true
                      ? null
                      : isUserInstrumentInSchedule
                      ? Colors.green
                      : Colors.red,
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
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventFormPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}