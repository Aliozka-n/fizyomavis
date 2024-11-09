// lib/data/repositories/exercise_repository.dart

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/exercise_model.dart';

class ExerciseRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'exercises.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE exercises(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            category TEXT,
            imageUrl TEXT,
            isSelected INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Exercise>> getExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');

    return List.generate(maps.length, (i) {
      final data = maps[i];
      return Exercise(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        category: data['category'],
        imageUrl: data['imageUrl'],
        isSelected: data['isSelected'] == 1,
      );
    });
  }

  Future<void> addExercise(Exercise exercise) async {
    final db = await database;
    await db.insert(
      'exercises',
      {
        'id': exercise.id,
        'title': exercise.title,
        'description': exercise.description,
        'category': exercise.category,
        'imageUrl': exercise.imageUrl,
        'isSelected': exercise.isSelected ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await database;
    await db.update(
      'exercises',
      {
        'title': exercise.title,
        'description': exercise.description,
        'category': exercise.category,
        'imageUrl': exercise.imageUrl,
        'isSelected': exercise.isSelected ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> deleteExercise(String id) async {
    final db = await database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(join(directory.path, 'exercise_images'));

    // Klasörü oluştur
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imagePath = join(imagesDir.path, fileName);

    // Resmi kopyala
    await image.copy(imagePath);
    return imagePath;
  }
}
