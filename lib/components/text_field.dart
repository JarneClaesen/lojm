import 'package:flutter/material.dart';

import '../helper/style_constants.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
          borderRadius: StyleConstants.largeRoundedCorner,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: StyleConstants.largeRoundedCorner,
        ),
        fillColor: Theme.of(context).colorScheme.primaryContainer,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),

      ),
    );
  }
}