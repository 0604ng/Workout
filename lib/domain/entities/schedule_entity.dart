class ScheduleEntity {
  final String weekId;
  final String userId;
  final Map<String, List<String>> days; // monday: [exerciseIds]

  ScheduleEntity({
    required this.weekId,
    required this.userId,
    required this.days,
  });

  factory ScheduleEntity.fromMap(String id, Map<String, dynamic> json) {
    return ScheduleEntity(
      weekId: id,
      userId: json['userId'],
      days: Map<String, List<String>>.from(
        json['days']?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'days': days,
  };
}
