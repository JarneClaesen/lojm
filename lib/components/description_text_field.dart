import 'package:flutter/material.dart';

import '../helper/style_constants.dart';

class DescriptionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const DescriptionTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null, // Allows for multiple lines
      keyboardType: TextInputType.multiline,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
          borderRadius: StyleConstants.largeRoundedCorner,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: StyleConstants.largeRoundedCorner,
        ),
        fillColor: Theme.of(context).colorScheme.primary,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}