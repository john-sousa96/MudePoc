class Event {
  int? id;
  String name;
  String location;
  String date;
  String time;
  String description;

  Event({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.description
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'date': date,
      'time': time,
      'description': description
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, int id) {
    return Event(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
