import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/helper_methods.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(event['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[500]),
                const SizedBox(width: 5),
                Expanded(child: Text('Location: ${event['location']}', style: TextStyle(fontSize: 16))),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.grey[500]),
                const SizedBox(width: 5),
                Text('Date: ${formatDate(event['date'] as Timestamp)}', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.timer, color: Colors.grey[500]),
                const SizedBox(width: 5),
                Text('Start Time: ${formatTime(event['eventStartTime'] as Timestamp)}', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.timer_off, color: Colors.grey[500]),
                const SizedBox(width: 5),
                Text('End Time: ${formatTime(event['eventEndTime'] as Timestamp)}', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey[400]),
            SizedBox(height: 20),
            Text('Schedule:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 10),
            ...List<Widget>.from((event['schedules'] as List).map((schedule) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text('Piece: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text('${schedule['piece']}', style: TextStyle(fontSize: 16))),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text('Conductor: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text('${schedule['conductor']}', style: TextStyle(fontSize: 16))),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.grey[500]),
                        const SizedBox(width: 5),
                        Text('Start Time: ${formatTime(schedule['startTime'] as Timestamp)}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text('Instruments: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text('${(schedule['instruments'] as List).join(', ')}', style: TextStyle(fontSize: 16))),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }
}
