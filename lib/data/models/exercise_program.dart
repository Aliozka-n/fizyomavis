// lib/data/models/exercise_program.dart

class ExerciseProgram {
  final String id;
  final String name;
  final String description;
  final int weekDuration; // Program süresi (hafta)
  final Map<int, List<String>> weeklyExercises; // Haftalık egzersiz ID'leri
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.weekDuration,
    required this.weeklyExercises,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON'dan oluşturma
  factory ExerciseProgram.fromJson(Map<String, dynamic> json) {
    return ExerciseProgram(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      weekDuration: json['weekDuration'],
      weeklyExercises: Map<int, List<String>>.from(
        json['weeklyExercises'].map(
          (key, value) => MapEntry(
            int.parse(key),
            List<String>.from(value),
          ),
        ),
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weekDuration': weekDuration,
      'weeklyExercises': weeklyExercises.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Kopyalama metodu
  ExerciseProgram copyWith({
    String? name,
    String? description,
    int? weekDuration,
    Map<int, List<String>>? weeklyExercises,
    String? notes,
  }) {
    return ExerciseProgram(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weekDuration: weekDuration ?? this.weekDuration,
      weeklyExercises: weeklyExercises ?? this.weeklyExercises,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
