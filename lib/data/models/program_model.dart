// lib/data/models/program_model.dart

class Program {
  final String id;
  final String name;
  final String description;
  final List<String> exerciseIds;
  final DateTime createdAt;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.exerciseIds,
    required this.createdAt,
  });

  // Map'ten oluşturma
  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      exerciseIds: List<String>.from(map['exerciseIds']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exerciseIds': exerciseIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Kopyalama
  Program copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? exerciseIds,
    DateTime? createdAt,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
