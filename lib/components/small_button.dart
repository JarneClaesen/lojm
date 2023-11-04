import 'package:flutter/material.dart';

import '../helper/style_constants.dart';

class SmallCustomButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final IconData? icon;
  final double? horizontalMargin;

  const SmallCustomButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.icon,
    this.horizontalMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin ?? 0,),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: StyleConstants.largeRoundedCorner,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Theme.of(context).colorScheme.primaryContainer),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}