import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:orchestra_app/components/comment_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/helper_methods.dart';
import '../helper/style_constants.dart';
import 'comment.dart';
import 'delete_button.dart';
import 'like_button.dart';
import 'dart:core';

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
  var data;

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
    return Stack(
      children: [
        _buildMainContainer(context),
        _buildLikeButton(),
        if (widget.user == currentUser?.email) _buildDeleteButton(),
      ],
    );
  }

  Widget _buildMainContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: StyleConstants.largeRoundedCorner,
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 0),
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserName(),
          _buildWallPost(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      '${widget.firstName} ${widget.lastName}',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWallPost() {
    String? url = _extractUrlFromString(widget.message);

    // Build a text style for links
    final linkStyle = TextStyle(color: Colors.blue, decoration: TextDecoration.underline);

    // Get spans for text and links
    final spans = _getTextSpans(widget.message, TextStyle(color: Theme.of(context).colorScheme.onSurface), linkStyle);


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.date, style: TextStyle(color: Colors.grey[400])),
            Text(' at ', style: TextStyle(color: Colors.grey[400])),
            Text(widget.time, style: TextStyle(color: Colors.grey[400])),
          ],
        ),
        const SizedBox(height: 5),
        // Check if URL is not null before showing the SimpleLinkPreview
        if (url != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16), // Use the desired border radius
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Transform.translate(
                offset: Offset(0, 0),
                child: LinkPreview(
                  openOnPreviewImageTap: true,
                  openOnPreviewTitleTap: true,
                  text: url,
                  onPreviewDataFetched: (dataFromUrl) {
                    setState(() {
                      data = dataFromUrl;
                    });
                  },
                  previewData: data,
                  width: MediaQuery.of(context).size.width,
                  linkStyle: TextStyle(
                    fontSize: 0, // Hides the link by setting the font size to zero
                  ),
                  metadataTextStyle: TextStyle(
                    fontSize: 0, // Hides the metadata by setting the font size to zero
                  ),
                  padding: EdgeInsets.only(top: 0.01, left: 10, right: 10),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            children: spans,
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton() {
    return Positioned(
      bottom: 0,  // Increase this value if you want more space
      left: 31,
      child: Row(
        children: [
          LikeButton(
            isLiked: isLiked,
            onTap: toggleLike,
          ), // This will give horizontal spacing between the button and the text
          Text(
            widget.likes.length.toString(),
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }


  Widget _buildDeleteButton() {
    return Positioned(
      top: 40,
      right: 40,
      child: DeleteButton(onTap: deletePost),
    );
  }

  String? _extractUrlFromString(String text) {
    final RegExp urlExp = RegExp(
      r'(\b(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+(\/[^\s]*)?\b)',
      caseSensitive: false,
      multiLine: false,
    );

    // Attempt to find a match in the given text.
    final matches = urlExp.allMatches(text);
    if (matches.isNotEmpty) {
      // Return the first URL match found.
      return matches.first.group(0);
    }
    return null; // Return null if no URL is found.
  }

  List<InlineSpan> _getTextSpans(String text, TextStyle style, TextStyle linkStyle) {
    final RegExp urlExp = RegExp(
      r'(\bhttps?:\/\/[\-A-Za-z0-9+&@#/%?=~_|!:,.;]*[\-A-Za-z0-9+&@#/%=~_|])',
      caseSensitive: false,
    );

    List<InlineSpan> spans = [];
    text.splitMapJoin(
      urlExp,
      onMatch: (Match match) {
        final String matchText = match[0]!;
        spans.add(
          WidgetSpan(
            child: InkWell(
              child: Text(
                matchText,
                style: linkStyle.copyWith(decoration: TextDecoration.underline),
              ),
              onTap: () async {
                final Uri uri = Uri.parse(matchText);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  // Handle the error or inform the user they cannot open the URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not launch $matchText'),
                    ),
                  );
                }
              },
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String text) {
        spans.add(TextSpan(text: text, style: style));
        return '';
      },
    );
    return spans;
  }




}