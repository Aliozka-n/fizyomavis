// lib/data/repositories/exercise_repository.dart

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/exercise_model.dart'; // Bu satır düzeltildi

class ExerciseRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'exercises.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE exercises (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            isSelected INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Resmi kaydet
  Future<String> saveImage(File image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesPath = join(appDir.path, 'exercise_images');

      // Klasör yoksa oluştur
      final imagesDir = Directory(imagesPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Benzersiz dosya adı oluştur
      final String fileName = 'exercise_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = join(imagesPath, fileName);

      // Resmi kopyala
      await image.copy(filePath);

      return filePath;
    } catch (e) {
      print('Resim kaydedilirken hata: $e');
      throw Exception('Resim kaydedilirken bir hata oluştu');
    }
  }

  // Egzersiz ekle
  Future<void> addExercise(Exercise exercise) async {
    try {
      final db = await database;
      await db.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Egzersiz eklenirken hata: $e');
      throw Exception('Egzersiz veritabanına eklenirken bir hata oluştu');
    }
  }

  // Tüm egzersizleri getir
  Future<List<Exercise>> getExercises() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('exercises');

      return List.generate(maps.length, (i) {
        return Exercise.fromMap(maps[i]);
      });
    } catch (e) {
      print('Egzersizler getirilirken hata: $e');
      throw Exception('Egzersizler veritabanından getirilirken bir hata oluştu');
    }
  }

  // Egzersiz sil
  Future<void> deleteExercise(String id) async {
    try {
      final db = await database;
      await db.delete(
        'exercises',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Egzersiz silinirken hata: $e');
      throw Exception('Egzersiz veritabanından silinirken bir hata oluştu');
    }
  }
}
