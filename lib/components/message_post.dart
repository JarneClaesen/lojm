import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/components/comment_button.dart';

import '../helper/helper_methods.dart';
import 'comment.dart';
import 'delete_button.dart';
import 'like_button.dart';

class messagePost extends StatefulWidget {

  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;

  const messagePost({
    Key? key,
    required this.message,
    required this.user,
    //required this.time,
    required this.postId,
    required this.likes,
    required this.time,
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
      'CommentTime': Timestamp.now(), // todo format this
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
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
          SizedBox(width: 20),

          // wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group of text (message + user email)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // message
                  Text(widget.message),

                  const SizedBox(height: 5),

                  // user
                  Row(
                    children: [
                      Text(widget.user, style: TextStyle(color: Colors.grey[400])),
                      Text('.', style: TextStyle(color: Colors.grey[400])),
                      Text(widget.time, style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LIKE
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

              const SizedBox(width: 10),

              // COMMENT
              Column(
                children: [
                  CommentButton(onTap: showComentDialog),

                  const SizedBox(height: 5),

                  // Comment count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
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