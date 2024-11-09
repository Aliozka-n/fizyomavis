// lib/data/models/exercise_model.dart

class Exercise {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  bool isSelected;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.isSelected = false,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'isSelected': isSelected,
      };

  // JSON deserialization
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        imageUrl: json['imageUrl'],
        isSelected: json['isSelected'] ?? false,
      );

  // Copy with method for immutability
  Exercise copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    bool? isSelected,
  }) {
    return Exercise(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
