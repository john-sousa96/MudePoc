class CheckInModel {
  final int? id;
  final int eventId;
  final double latitude;
  final double longitude;
  final String timestamp;

  CheckInModel({
    this.id,
    required this.eventId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }

  factory CheckInModel.fromMap(Map<String, dynamic> map, [int? id]) {
    return CheckInModel(
      id: id,
      eventId: map['event_id'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: map['timestamp'] as String,
    );
  }
}