import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../db_helper.dart';
import '../models/schedule.dart';

class AddSchedulePage extends StatefulWidget {
  final DateTime initialDate;

  AddSchedulePage({required this.initialDate});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _location = '';
  Color _selectedColor = Colors.blue;
  String _dressCode = '';
  DateTime _startDate;
  DateTime _endDate;
  bool _allDay = false;
  File? _image1;
  File? _image2;
  File? _image3;

  List<CustomField> _customFields = [];

  _AddSchedulePageState()
      : _startDate = DateTime.now(),
        _endDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate;
    _endDate = widget.initialDate.add(const Duration(hours: 1));
  }

  Future<void> _pickImage(int index) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (index == 1) _image1 = File(pickedFile.path);
        if (index == 2) _image2 = File(pickedFile.path);
        if (index == 3) _image3 = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<Map<String, String>> customFieldData = _customFields.map((field) {
        return {
          'title': field.titleController.text,
          'input': field.inputController.text,
          'logo': field.logo?.path ?? '',
        };
      }).toList();

      final newSchedule = Schedule(
        title: _title,
        description: _description,
        imagePath1: _image1?.path ?? '',
        imagePath2: _image2?.path ?? '',
        imagePath3: _image3?.path ?? '',
        startDate: _startDate,
        endDate: _endDate,
        location: _location,
        color: _selectedColor.value,
        dressCode: _dressCode,
        allDay: _allDay,
        customFields: customFieldData,
      );
      await DBHelper().insertSchedule(newSchedule);
      Navigator.of(context).pop();
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            enableAlpha: true,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Select'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
    int v = sqrt(pow(backgroundColor.red, 2) * 0.299 +
            pow(backgroundColor.green, 2) * 0.587 +
            pow(backgroundColor.blue, 2) * 0.114)
        .round();
    return v < 130 + bias;
  }

  Future<void> _confirmAddCustomField() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Field'),
        content: const Text('Do you want to add a new custom field?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _customFields.add(CustomField());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Add Schedule',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        leadingWidth: 90,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveSchedule,
              color: Colors.pink,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Add Title',
                  prefixIcon: Icon(Icons.title),
                ),
                onSaved: (value) {
                  _title = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(1),
                    child: _image1 != null
                        ? Image.file(_image1!,
                            width: 100, height: 100, fit: BoxFit.cover)
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.add_a_photo),
                          ),
                  ),
                  GestureDetector(
                    onTap: () => _pickImage(2),
                    child: _image2 != null
                        ? Image.file(_image2!,
                            width: 100, height: 100, fit: BoxFit.cover)
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.add_a_photo),
                          ),
                  ),
                  GestureDetector(
                    onTap: () => _pickImage(3),
                    child: _image3 != null
                        ? Image.file(_image3!,
                            width: 100, height: 100, fit: BoxFit.cover)
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.add_a_photo),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.clock),
                title: const Text('Time'),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwitchListTile(
                      title: const Text('All - day'),
                      value: _allDay,
                      onChanged: (value) {
                        setState(() {
                          _allDay = value;
                          if (_allDay) {
                            _startDate = DateTime(_startDate.year,
                                _startDate.month, _startDate.day, 0, 0);
                            _endDate = DateTime(_endDate.year, _endDate.month,
                                _endDate.day, 23, 59);
                          }
                        });
                      },
                    ),
                    if (!_allDay) ...[
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat.yMMMd().format(_startDate)),
                            Text(
                              DateFormat.Hm().format(_startDate),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final pickedStartDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedStartDate != null) {
                            final pickedStartTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_startDate),
                            );
                            if (pickedStartTime != null) {
                              setState(() {
                                _startDate = DateTime(
                                  pickedStartDate.year,
                                  pickedStartDate.month,
                                  pickedStartDate.day,
                                  pickedStartTime.hour,
                                  pickedStartTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat.yMMMd().format(_endDate)),
                            Text(
                              DateFormat.Hm().format(_endDate),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final pickedEndDate = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedEndDate != null) {
                            final pickedEndTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_endDate),
                            );
                            if (pickedEndTime != null) {
                              setState(() {
                                _endDate = DateTime(
                                  pickedEndDate.year,
                                  pickedEndDate.month,
                                  pickedEndDate.day,
                                  pickedEndTime.hour,
                                  pickedEndTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ]
                  ],
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.locationDot),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _location = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.palette),
                title: GestureDetector(
                  onTap: _pickColor,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        'Color',
                        style: TextStyle(
                          color: useWhiteForeground(_selectedColor)
                              ? Colors.white
                              : Colors
                                  .black, // Mengatur warna teks agar kontras
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.shirt),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Dresscode',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _dressCode = value!;
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Event Detail',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
              ),
              const Divider(),
              ..._customFields.map((field) => ListTile(
                    leading: GestureDetector(
                      onTap: () => field.pickLogo(context),
                      child: field.logo != null
                          ? Image.file(field.logo!,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.add),
                            ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: field.titleController,
                          decoration: const InputDecoration(
                            labelText: 'Field Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: field.inputController,
                                decoration: const InputDecoration(
                                  labelText: 'Input',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                onPressed: _confirmAddCustomField,
                child: const Text('Add Custom Field'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomField {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController inputController = TextEditingController();
  File? logo;

  Future<void> pickLogo(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      logo = File(pickedFile.path);
      (context as Element).markNeedsBuild(); // Update the UI
    }
  }
}
