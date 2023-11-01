import 'package:flutter/material.dart';

import '../helper/style_constants.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        //height: 50,
        //width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface, // todo kleur van de button aanpassen zodat het in light mode zwart is en iets anders in dark mode
          borderRadius: StyleConstants.largeRoundedCorner,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}