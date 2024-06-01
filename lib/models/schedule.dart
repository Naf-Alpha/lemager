import 'dart:convert';

class Schedule {
  final int? id;
  late final String title;
  late final String description;
  final String imagePath1;
  final String imagePath2;
  final String imagePath3;
  late final DateTime startDate;
  late final DateTime endDate;
  late final String location;
  late final int color;
  late final String dressCode;
  final bool allDay;
  late final List<Map<String, String>> customFields;

  Schedule({
    this.id,
    required this.title,
    required this.description,
    required this.imagePath1,
    required this.imagePath2,
    required this.imagePath3,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.color,
    required this.dressCode,
    required this.allDay,
    required this.customFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath1': imagePath1,
      'imagePath2': imagePath2,
      'imagePath3': imagePath3,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'location': location,
      'color': color,
      'dressCode': dressCode,
      'allDay': allDay ? 1 : 0,
      'customFields': jsonEncode(customFields),
    };
  }

  static Schedule fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath1: map['imagePath1'],
      imagePath2: map['imagePath2'],
      imagePath3: map['imagePath3'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      location: map['location'],
      color: map['color'],
      dressCode: map['dressCode'],
      allDay: map['allDay'] == 1,
      customFields: List<Map<String, String>>.from(
        (jsonDecode(map['customFields']) as List).map(
          (item) => Map<String, String>.from(item),
        ),
      ),
    );
  }
}
