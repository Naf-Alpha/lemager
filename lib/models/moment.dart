class Moment {
  final int? id;
  String title;
  final String description;
  final String imagePath;
  final DateTime date;

  Moment({
    this.id,
    this.title = '', // Provide a default empty string for the title
    required this.description,
    required this.imagePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
    };
  }
}
