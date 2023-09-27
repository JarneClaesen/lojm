import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/components/comment_button.dart';

import '../helper/helper_methods.dart';
import 'comment.dart';
import 'delete_button.dart';
import 'like_button.dart';

class messagePost extends StatefulWidget {

  final String firstName;
  final String lastName;
  final String message;
  final String user;
  final String date;
  final String time;
  final String postId;
  final List<String> likes;

  const messagePost({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.message,
    required this.user,
    required this.date,
    required this.time,
    required this.postId,
    required this.likes,
  }) : super(key: key);

  @override
  State<messagePost> createState() => _messagePostState();
}

class _messagePostState extends State<messagePost> {

  // user
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false;

  // comment text controller
  final _commentTextController = TextEditingController();

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
    DocumentReference postRef = FirebaseFirestore.instance.collection("messages").doc(widget.postId);

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

  // add a comment
  void addComment(String commentText) {
    FirebaseFirestore.instance.collection("messages").doc(widget.postId).collection("comments").add({
      'CommentText': commentText,
      'CommentedBy': currentUser?.email,
      'CommentTime': Timestamp.now(),
    });
  }

  // show a dialog box for adding comment
  void showComentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add a comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(
            hintText: "Enter your comment",
          ),
        ),
        actions: [

          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),

          // save button
          TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                Navigator.pop(context);
                _commentTextController.clear();
              },
              child: Text("Post"),
          ),
        ]
      ),
    );
  }

  // delete a post
  void deletePost() {
    // show dialog box for confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          // CANCEL BUTTON
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          // DELETE BUTTON
          TextButton(
            onPressed: () async {
              // delete the comments
              final commentDocs = await FirebaseFirestore.instance.collection("messages").doc(widget.postId).collection("comments").get();
              for (final doc in commentDocs.docs) {
                FirebaseFirestore.instance.collection("messages").doc(widget.postId).collection("comments").doc(doc.id).delete();
              }
              // delete the post
              FirebaseFirestore.instance
                  .collection("messages")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("Post Deleted")).catchError((error) => print("Failed to delete post: $error"));

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),

      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20),

          Row(
            children: [
              // user
              Text(
                widget.firstName + ' ' + widget.lastName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group of text (message + user email)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //const SizedBox(height: 3),

                  // DateTime
                  Row(
                    children: [
                      Text(widget.date, style: TextStyle(color: Colors.grey[400])),
                      Text(' at ', style: TextStyle(color: Colors.grey[400])),
                      Text(widget.time, style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // message
                  Text(widget.message),

                  const SizedBox(height: 5),



                  SizedBox(height: 10),


                ],
              ),

              // delete button
              if (widget.user == currentUser?.email)
                DeleteButton(onTap: deletePost)
            ],
          ),

          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              // LIKE
              Row(
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

              const SizedBox(width: 10),

            ],
          ),

          const SizedBox(height: 5),

          // comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).collection("Comments").orderBy("CommentTime", descending: true).snapshots(),
            builder: (context, snapshot) {
              // show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true, // for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  // get the comment
                  final commentData = doc.data() as Map<String, dynamic>;

                  // return a comment
                  return Comment(
                    text: commentData['CommentText'],
                    user: commentData['CommentedBy'],
                    time: formatDate(commentData['CommentTime']),
                  );
                }).toList(),
              );
            }
          )
        ],
      ),
    );
  }
}