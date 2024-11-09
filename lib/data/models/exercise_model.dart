// lib/data/models/exercise_model.dart

class Exercise {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final bool isSelected;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.isSelected = false,
  });

  // Map'ten Exercise oluştur
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      isSelected: map['isSelected'] == 1,
    );
  }

  // Exercise'i Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'isSelected': isSelected ? 1 : 0,
    };
  }

  // Kopyalama metodu
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

  // toString metodu (debugging için)
  @override
  String toString() {
    return 'Exercise(id: $id, title: $title, category: $category)';
  }
}
