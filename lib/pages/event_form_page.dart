import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../components/description_text_field.dart';
import '../components/small_button.dart';
import '../components/text_field.dart';

class EventFormPage extends StatefulWidget {
  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _eventStartTime;
  DateTime? _eventEndTime;
  List<ScheduleItem> _scheduleItems = [];

  final List<String> _instruments = [
    'Fluit', 'Hobo', 'Klarinet', 'Fagot', 'Hoorn', 'Trompet', 'Trombone', 'Tuba', 'Pauken', 'Percussion', 'Harp', 'Piano | Celesta', 'Strijkers'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Check if main event details are filled
    if (_titleController.text.isEmpty || _selectedDate == null || _eventStartTime == null || _eventEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    // Check if schedule items details are filled
    for (var item in _scheduleItems) {
      if (item.startTime == null || (!item.isBreak && (item.pieceController.text.isEmpty || item.conductorController.text.isEmpty))) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields in the schedule items.')));
        return;
      }
    }

    List<Map<String, dynamic>> schedules = _scheduleItems.map((item) {
      if (item.isBreak) {
        return {
          'isBreak': true,
          'startTime': item.startTime,
        };
      } else {
        return {
          'piece': item.pieceController.text,
          'conductor': item.conductorController.text,
          'startTime': item.startTime,
          'instruments': item.selectedInstruments,
        };
      }
    }).toList();

    await FirebaseFirestore.instance.collection('events').add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'date': _selectedDate,
      'eventStartTime': _eventStartTime,
      'eventEndTime': _eventEndTime,
      'schedules': schedules,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: TextButton(
              onPressed: _submitForm,
              child: Text('SAVE', style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer)),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
              )
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyTextField(controller: _titleController, hintText: 'Event Title', obscureText: false),
            SizedBox(height: 20),
            ListTile(
              title: Text(_selectedDate == null ? 'Select date' : '${DateFormat("dd-MM-yyyy").format(_selectedDate!)}'),
              leading: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text(_eventStartTime == null ? 'Start time' : '${_eventStartTime!.hour}:${_eventStartTime!.minute.toString().padLeft(2, '0')}'),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null && _selectedDate != null) {
                  setState(() {
                    _eventStartTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, pickedTime.hour, pickedTime.minute);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.timer_off),
              title: Text(_eventEndTime == null ? 'End time' : '${_eventEndTime!.hour}:${_eventEndTime!.minute.toString().padLeft(2, '0')}'),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null && _selectedDate != null) {
                  setState(() {
                    _eventEndTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, pickedTime.hour, pickedTime.minute);
                  });
                }
              },
            ),
            SizedBox(height: 20),
            MyTextField(controller: _locationController, hintText: 'Location', obscureText: false),
            SizedBox(height: 20),
            DescriptionTextField(controller: _descriptionController, hintText: 'Description'),
            SizedBox(height: 20),
            ..._buildScheduleItems(),
            SizedBox(height: 20),
            SmallCustomButton(
              onTap: () {
                setState(() {
                  _scheduleItems.add(ScheduleItem(instruments: _instruments));
                });
              },
              text: 'Add Schedule Item',
              icon: Icons.add,  // Provide the plus icon here
            ),
            const SizedBox(height: 20),
            SmallCustomButton(
              onTap: () {
                setState(() {
                  _scheduleItems.add(ScheduleItem(instruments: _instruments, isBreak: true));
                });
              },
              text: 'Add Break',
              icon: Icons.pause,  // You can choose another appropriate icon if needed
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScheduleItems() {
    return _scheduleItems.map((item) {
      if (item.isBreak) {
        return Column(
          children: [
            Divider(color: Colors.grey[400], height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _scheduleItems.remove(item);
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('BREAK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            ListTile( // Adding start time for break
              leading: Icon(Icons.timer),
              title: Text(item.startTime == null ? 'Select start time' : '${item.startTime!.hour}:${item.startTime!.minute.toString().padLeft(2, '0')}'),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null && _selectedDate != null) {
                  setState(() {
                    item.startTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, pickedTime.hour, pickedTime.minute);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      } else {
        return Column(
          children: [
            Divider(color: Colors.grey[400], height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _scheduleItems.remove(item);
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  MyTextField(controller: item.pieceController, hintText: 'Piece title', obscureText: false),
                  const SizedBox(height: 12),
                  MyTextField(controller: item.conductorController, hintText: 'Conductor', obscureText: false),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text(item.startTime == null ? 'Select start time' : '${item.startTime!.hour}:${item.startTime!.minute.toString().padLeft(2, '0')}'),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null && _selectedDate != null) {
                        setState(() {
                          item.startTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, pickedTime.hour, pickedTime.minute);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SmallCustomButton(
                    onTap: () {
                      setState(() {
                        if (item.selectedInstruments.length == _instruments.length) {
                          item.selectedInstruments.clear();
                        } else {
                          item.selectedInstruments.addAll(_instruments);
                        }
                      });
                    },
                    text: item.selectedInstruments.length == _instruments.length ? 'Deselect All' : 'Select All',
                    horizontalMargin: 125,
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _instruments.map((instrument) {
                      return ChoiceChip(
                        label: Text(instrument),
                        selected: item.selectedInstruments.contains(instrument),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              item.selectedInstruments.add(instrument);
                            } else {
                              item.selectedInstruments.remove(instrument);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }).toList();
  }
}

class ScheduleItem {
  TextEditingController pieceController = TextEditingController();
  TextEditingController conductorController = TextEditingController();
  DateTime? startTime;
  List<String> selectedInstruments = [];
  final List<String> instruments;
  bool isBreak;

  ScheduleItem({required this.instruments, this.isBreak = false});
}