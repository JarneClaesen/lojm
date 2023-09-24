import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const MyListTile({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
            icon,
            color: Colors.white,
        ),
        onTap: onTap,
        title: Text(
            text,
            style: TextStyle(
                color: Colors.white,
                //fontSize: 16,
            ),
        ),
      ),
    );
  }
}