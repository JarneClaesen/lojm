import 'package:flutter/material.dart';

class MyMessageTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final double maxHeight;  // Define a maxHeight parameter

  const MyMessageTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.maxHeight = 150.0,  // You can adjust this value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),  // Set maximum height
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Vertical scrolling
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: null,  // Unlimited number of lines
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            fillColor: Theme.of(context).colorScheme.primary,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}

