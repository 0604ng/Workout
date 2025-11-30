class CustomExerciseEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int durationSeconds;
  final String difficulty;
  final int sets;
  final int reps;
  final int calories;
  final String imageUrl;

  CustomExerciseEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.difficulty,
    required this.sets,
    required this.reps,
    required this.calories,
    required this.imageUrl,
  });

  factory CustomExerciseEntity.fromMap(String id, Map<String, dynamic> json) {
    return CustomExerciseEntity(
      id: id,
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      durationSeconds: json['durationSeconds'],
      difficulty: json['difficulty'],
      sets: json['sets'],
      reps: json['reps'],
      calories: json['calories'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'description': description,
    'durationSeconds': durationSeconds,
    'difficulty': difficulty,
    'sets': sets,
    'reps': reps,
    'calories': calories,
    'imageUrl': imageUrl,
  };
}
