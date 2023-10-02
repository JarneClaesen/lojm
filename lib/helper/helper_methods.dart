// return a formatted data as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  String year = dateTime.year.toString();
  String month = dateTime.month.toString();
  String day = dateTime.day.toString();

  String formattedDate = "$day/$month/$year";
  return formattedDate;
}

String formatTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  String hour = dateTime.hour.toString();
  String minute = dateTime.minute.toString().padLeft(2, '0');

  String formattedTime = "$hour:$minute";
  return formattedTime;
}