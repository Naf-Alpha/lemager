import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/schedule.dart';
import 'edit_schedule_page.dart';

class ScheduleDetailPage extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onDelete;
  final ValueChanged<Schedule> onEdit;

  const ScheduleDetailPage({
    Key? key,
    required this.schedule,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
    int v = sqrt(pow(backgroundColor.red, 2) * 0.299 +
            pow(backgroundColor.green, 2) * 0.587 +
            pow(backgroundColor.blue, 2) * 0.114)
        .round();
    return v < 130 + bias;
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this schedule?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                _deleteSchedule(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSchedule(BuildContext context) {
    onDelete(); // Notify the parent widget about the deletion
    Navigator.of(context).pop(); // Close the confirmation dialog
    Navigator.of(context).pop(
        true); // Close the detail page and return true to indicate deletion
  }

  void _editSchedule(BuildContext context) async {
    final editedSchedule = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSchedulePage(schedule: schedule),
      ),
    );

    if (editedSchedule != null) {
      onEdit(editedSchedule); // Notify the parent widget about the edit
      Navigator.of(context).pop(editedSchedule); // Return edited schedule
    }
  }

  void _openFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Schedule Details',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        leadingWidth: 90,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => _editSchedule(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              schedule.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            if (schedule.imagePath1.isNotEmpty ||
                schedule.imagePath2.isNotEmpty ||
                schedule.imagePath3.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (schedule.imagePath1.isNotEmpty)
                    GestureDetector(
                      onTap: () =>
                          _openFullScreenImage(context, schedule.imagePath1),
                      child: Image.file(File(schedule.imagePath1),
                          width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  if (schedule.imagePath2.isNotEmpty)
                    GestureDetector(
                      onTap: () =>
                          _openFullScreenImage(context, schedule.imagePath2),
                      child: Image.file(File(schedule.imagePath2),
                          width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  if (schedule.imagePath3.isNotEmpty)
                    GestureDetector(
                      onTap: () =>
                          _openFullScreenImage(context, schedule.imagePath3),
                      child: Image.file(File(schedule.imagePath3),
                          width: 100, height: 100, fit: BoxFit.cover),
                    ),
                ],
              ),
            const SizedBox(height: 30.0),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.calendar),
              title: const Text('Date'),
              subtitle: Text(
                '${DateFormat.yMMMd().format(schedule.startDate)} - ${DateFormat.yMMMd().format(schedule.endDate)}',
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.clock),
              title: const Text('Time'),
              subtitle: Text(
                schedule.allDay
                    ? 'All day'
                    : '${DateFormat.Hm().format(schedule.startDate)} - ${DateFormat.Hm().format(schedule.endDate)}',
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.locationDot),
              title: const Text('Location'),
              subtitle: Text(schedule.location),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.palette),
              subtitle: Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  color: Color(schedule.color),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    colorToHex(Color(schedule.color)),
                    style: TextStyle(
                      color: useWhiteForeground(Color(schedule.color))
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.shirt),
              title: const Text('Dresscode'),
              subtitle: Text(schedule.dressCode),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Event Detail'),
              subtitle: Text(schedule.description),
            ),
            const Divider(),
            if (schedule.customFields.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Fields',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...schedule.customFields.map((field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: field['logo']!.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => _openFullScreenImage(
                                      context, field['logo']!),
                                  child: Image.file(File(field['logo']!),
                                      width: 50, height: 50, fit: BoxFit.cover),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.add),
                                ),
                          title: Text(field['title']!),
                          subtitle: Text(field['input']!),
                        ),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullScreenImagePage({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Full Image', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
