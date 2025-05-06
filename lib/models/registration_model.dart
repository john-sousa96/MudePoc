class Registration {
  final int eventId;
  final bool isRegistered;
  final bool hasCheckedIn;
  final DateTime? registrationDate;
  final DateTime? checkInDate;

  Registration({
    required this.eventId,
    required this.isRegistered,
    required this.hasCheckedIn,
    this.registrationDate,
    this.checkInDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'is_registered': isRegistered ? 1 : 0,
      'has_checked_in': hasCheckedIn ? 1 : 0,
      'registration_date': registrationDate?.toIso8601String(),
      'check_in_date': checkInDate?.toIso8601String(),
    };
  }

  factory Registration.fromMap(Map<String, dynamic> map) {
    return Registration(
      eventId: map['event_id'],
      isRegistered: map['is_registered'] == 1,
      hasCheckedIn: map['has_checked_in'] == 1,
      registrationDate: map['registration_date'] != null
          ? DateTime.parse(map['registration_date'])
          : null,
      checkInDate: map['check_in_date'] != null
          ? DateTime.parse(map['check_in_date'])
          : null,
    );
  }
}