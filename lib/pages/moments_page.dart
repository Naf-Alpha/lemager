import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart'; // Add this import for the basename function
import '../db_helper.dart';
import '../models/moment.dart';

class MomentsPage extends StatefulWidget {
  @override
  _MomentsPageState createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  Map<DateTime, List<Moment>> _moments = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMoments();
  }

  Future<void> _fetchMoments() async {
    final moments = await DBHelper().getMoments();
    setState(() {
      _moments = {};
      for (var moment in moments) {
        final date =
            DateTime(moment.date.year, moment.date.month, moment.date.day);
        if (_moments[date] == null) _moments[date] = [];
        _moments[date]!.add(moment);
      }
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      List<Moment> newMoments = pickedFiles
          .map((e) =>
              Moment(imagePath: e.path, date: _selectedDate, description: ''))
          .toList();
      for (var moment in newMoments) {
        await DBHelper().insertMoment(moment);
      }
      await _fetchMoments();
    }
  }

  Future<void> _confirmDeleteImage(BuildContext context, Moment moment) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteImage(moment);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteImage(Moment moment) async {
    await DBHelper().deleteMoment(moment.id!);
    await _fetchMoments();
  }

  Future<void> _downloadImage(Moment moment) async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path = directory?.path;
      if (path != null) {
        final fileName =
            basename(moment.imagePath); // Using basename from path package
        final savedPath = '$path/$fileName';
        final file = File(moment.imagePath);
        final savedFile = await file.copy(savedPath);
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Image saved to ${savedFile.path}')),
        );
      }
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Storage permission not granted')),
      );
    }
  }

  void _editMomentTitle(BuildContext context, DateTime date) {
    String? currentTitle = _moments[date]?.first.title ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = currentTitle;
        return AlertDialog(
          title: const Text('Edit Title'),
          content: TextFormField(
            initialValue: currentTitle,
            onChanged: (value) {
              newTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter new title'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  for (var moment in _moments[date]!) {
                    moment.title = '';
                    DBHelper().updateMoment(moment); // Remove title from DB
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.delete),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  for (var moment in _moments[date]!) {
                    moment.title = newTitle;
                    DBHelper().updateMoment(moment); // Save title to DB
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImagePage(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Moments', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
      ),
      body: CustomScrollView(
        slivers: _moments.entries.map((entry) {
          DateTime date = entry.key;
          List<Moment> moments = entry.value;
          String? title = moments.isNotEmpty ? moments.first.title : '';
          return SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                title: Row(
                  children: [
                    Expanded(
                        child: Text(DateFormat('EEE, MMM y').format(date))),
                    if (title.isNotEmpty)
                      Text(title,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                leading: CircleAvatar(
                  child: Text(date.day.toString()),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editMomentTitle(context, date),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moments.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final moment = moments[index];
                  return GestureDetector(
                    onTap: () => _showFullImage(context, moment.imagePath),
                    child: Card(
                      child: Stack(
                        children: [
                          Image.file(
                            File(moment.imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  color: Colors.white,
                                  onPressed: () => _downloadImage(moment),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () =>
                                      _confirmDeleteImage(context, moment),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ]),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null && picked != _selectedDate) {
            setState(() {
              _selectedDate = picked;
            });
          }
          await _pickImages();
        },
        label: const Text(
          'Upload Image',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final String imagePath;

  const FullImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
      backgroundColor: Colors.black,
    );
  }
}
