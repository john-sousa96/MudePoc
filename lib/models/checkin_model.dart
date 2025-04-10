class CheckInModel {
  final int? id;
  final double latitude;
  final double longitude;
  final String timestamp;

  CheckInModel({this.id, required this.latitude, required this.longitude, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'CheckIn: $latitude, $longitude @ $timestamp';
  }
}