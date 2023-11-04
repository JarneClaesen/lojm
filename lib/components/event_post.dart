import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../helper/style_constants.dart';
import '../pages/event_details_page.dart';

class EventPost extends StatelessWidget {
  final DateTime date;
  final String title;
  final String startTime;
  final String endTime;
  final String location;
  final Map<String, dynamic> eventData;
  final Color? dotColor;
  final bool isAdmin;

  const EventPost({
    Key? key,
    required this.date,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventData,
    this.dotColor,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EventDetailsPage(event: eventData),
        ));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: StyleConstants.largeRoundedCorner,
            ),
            margin: EdgeInsets.only(top: 25, left: 25, right: 25),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (dotColor != null)
                      CircleAvatar(
                        backgroundColor: dotColor,
                        radius: 5.0,
                      ),
                    if (dotColor != null)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      Text(
                          "${date.day}/${date.month}/${date.year}"
                      ),
                    ]
                ),
                const SizedBox(height: 10),
                Row(
                    children: [
                      Icon(Icons.timer, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      Text("$startTime - $endTime"),
                    ]
                ),
                const SizedBox(height: 10),
                Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      Text(location),
                    ]
                ),
              ],
            ),
          ),
          if (isAdmin)
            Positioned(
              top: 40,
              right: 40,
              child: GestureDetector(
                onTap: () async {
                  bool? shouldDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Set the background color of the dialog
                      title: Text(
                        'Delete Event',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set the text color for the title
                      ),
                      content: Text(
                        'Are you sure you want to delete this event?',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set the text color for the content
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set the text color for the cancel button
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Set the text color for the delete button
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true && eventData['id'] != null) {
                    print('Deleting event with ID: ${eventData['id']}');
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(eventData['id'])
                        .delete()
                        .then((value) => print("Event Deleted"))
                        .catchError((error) => print("Failed to delete event: $error"));
                  } else if (eventData['id'] == null) {
                    print("Event ID is null. Cannot delete.");
                  }
                },
                child: Icon(Icons.cancel),
              ),
            ),
        ],
      ),
    );
  }
}