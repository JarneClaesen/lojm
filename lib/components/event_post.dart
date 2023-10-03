import 'package:flutter/material.dart';

import '../pages/event_details_page.dart';

class EventPost extends StatelessWidget {
  final DateTime date;
  final String title;
  final String startTime;
  final String endTime;
  final String location;
  final Map<String, dynamic> eventData;
  final Color? dotColor;

  const EventPost({
    Key? key,
    required this.date,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventData,
    this.dotColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EventDetailsPage(event: eventData),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
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
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[500]),
                const SizedBox(width: 5),
                Text(location),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
