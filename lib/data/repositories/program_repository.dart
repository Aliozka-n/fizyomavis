// lib/data/repositories/program_repository.dart

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/program_model.dart';

class ProgramRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'programs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE programs(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            exerciseIds TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addProgram(Program program) async {
    try {
      final db = await database;
      await db.insert(
        'programs',
        {
          'id': program.id,
          'name': program.name,
          'description': program.description,
          'exerciseIds': program.exerciseIds.join(','),
          'createdAt': program.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Add program error: $e');
      rethrow;
    }
  }

  Future<List<Program>> getPrograms() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('programs');

      return List.generate(maps.length, (i) {
        return Program(
          id: maps[i]['id'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          exerciseIds: maps[i]['exerciseIds'].split(','),
          createdAt: DateTime.parse(maps[i]['createdAt']),
        );
      });
    } catch (e) {
      print('Get programs error: $e');
      rethrow;
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      final db = await database;
      await db.delete(
        'programs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Delete program error: $e');
      rethrow;
    }
  }

  Future<Program?> getProgramById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'programs',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      return Program(
        id: maps[0]['id'],
        name: maps[0]['name'],
        description: maps[0]['description'],
        exerciseIds: maps[0]['exerciseIds'].split(','),
        createdAt: DateTime.parse(maps[0]['createdAt']),
      );
    } catch (e) {
      print('Get program by id error: $e');
      rethrow;
    }
  }
}
