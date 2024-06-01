import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import '../db_helper.dart';

class EditSchedulePage extends StatefulWidget {
  final Schedule schedule;

  const EditSchedulePage({Key? key, required this.schedule}) : super(key: key);

  @override
  _EditSchedulePageState createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _dressCodeController;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _allDay;
  late int _color;
  late List<Map<String, String>> _customFields;
  String? _imagePath1;
  String? _imagePath2;
  String? _imagePath3;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule.title);
    _descriptionController =
        TextEditingController(text: widget.schedule.description);
    _locationController = TextEditingController(text: widget.schedule.location);
    _dressCodeController =
        TextEditingController(text: widget.schedule.dressCode);
    _startDate = widget.schedule.startDate;
    _endDate = widget.schedule.endDate;
    _startTime = TimeOfDay.fromDateTime(widget.schedule.startDate);
    _endTime = TimeOfDay.fromDateTime(widget.schedule.endDate);
    _allDay = widget.schedule.allDay;
    _color = widget.schedule.color;
    _customFields =
        List<Map<String, String>>.from(widget.schedule.customFields);
    _imagePath1 = widget.schedule.imagePath1;
    _imagePath2 = widget.schedule.imagePath2;
    _imagePath3 = widget.schedule.imagePath3;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _startTime.hour,
            _startTime.minute,
          );
        } else {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          _startDate = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          );
        } else {
          _endTime = pickedTime;
          _endDate = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source, int imageIndex) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (imageIndex == 1) {
          _imagePath1 = pickedFile.path;
        } else if (imageIndex == 2) {
          _imagePath2 = pickedFile.path;
        } else if (imageIndex == 3) {
          _imagePath3 = pickedFile.path;
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final updatedSchedule = Schedule(
        id: widget.schedule.id,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        dressCode: _dressCodeController.text,
        startDate: _startDate,
        endDate: _endDate,
        allDay: _allDay,
        color: _color,
        customFields: _customFields,
        imagePath1: _imagePath1 ?? '',
        imagePath2: _imagePath2 ?? '',
        imagePath3: _imagePath3 ?? '',
      );

      await DBHelper().updateSchedule(updatedSchedule);
      Navigator.of(context).pop(updatedSchedule);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dressCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _dressCodeController,
                decoration: const InputDecoration(labelText: 'Dress Code'),
              ),
              SwitchListTile(
                title: const Text('All Day'),
                value: _allDay,
                onChanged: (bool value) {
                  setState(() {
                    _allDay = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat.yMMMd().format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              if (!_allDay)
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(_startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, true),
                ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(DateFormat.yMMMd().format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              if (!_allDay)
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(_endTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, false),
                ),
              ListTile(
                title: const Text('Color'),
                trailing: CircleAvatar(
                  backgroundColor: Color(_color),
                ),
                onTap: () async {
                  final pickedColor = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pick a color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: Color(_color),
                          onColorChanged: (color) {
                            setState(() {
                              _color = color.value;
                            });
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Select'),
                          onPressed: () {
                            Navigator.of(context).pop(Color(_color));
                          },
                        ),
                      ],
                    ),
                  );
                  if (pickedColor != null) {
                    setState(() {
                      _color = pickedColor.value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSchedule,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
