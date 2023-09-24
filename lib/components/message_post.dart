import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'like_button.dart';

class messagePost extends StatefulWidget {

  final String message;
  final String user;
  //final String time;
  final String postID;
  final List<String> likes;

  const messagePost({
    Key? key,
    required this.message,
    required this.user,
    //required this.time,
    required this.postID,
    required this.likes,
  }) : super(key: key);

  @override
  State<messagePost> createState() => _messagePostState();
}

class _messagePostState extends State<messagePost> {

  // user
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser!.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document in Firebase
    DocumentReference postRef = FirebaseFirestore.instance.collection("messages").doc(widget.postID);

    if (isLiked) {
      // Add the user's email to the list of likes
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser!.email])
      });
    } else {
      // Remove the user's email from the list of likes
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser!.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),

      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            children: [
              LikeButton(
                isLiked: isLiked,
                onTap: toggleLike,
              ),

              Text(
                widget.likes.length.toString(),
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.user,
                style: TextStyle(
                  color: Colors.grey[500],
                )
              ),
              SizedBox(height: 10),
              Text(widget.message),
            ],
          )
        ],
      ),
    );
  }
}