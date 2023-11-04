import 'package:flutter/material.dart';

import '../helper/style_constants.dart';

class MyDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const MyDropdown({
    Key? key,
    required this.items,
    this.selectedItem,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MyDropdownState createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  String? _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: StyleConstants.largeRoundedCorner,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: StyleConstants.largeRoundedCorner,
          value: _currentItem,
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: StyleConstants.largeRoundedCorner,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text(item, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _currentItem = newValue;
            });
            widget.onChanged(newValue); // notify the parent about the change
          },
          dropdownColor: Theme.of(context).colorScheme.primaryContainer,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          hint: Text(
            "Select your instrument",
            style: TextStyle(color: Colors.grey[500]),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
        ),
      ),
    );
  }
}
