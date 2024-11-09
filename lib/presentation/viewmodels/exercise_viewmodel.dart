// lib/presentation/viewmodels/exercise_viewmodel.dart

import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _repository;

  ExerciseViewModel(this._repository) {
    loadExercises();
  }

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Exercise> get selectedExercises => _exercises.where((e) => e.isSelected).toList();

  // Egzersiz seçimini değiştir
  void toggleExercise(String id) {
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      final exercise = _exercises[index].copyWith(isSelected: !_exercises[index].isSelected);
      _exercises[index] = exercise;
      _repository.updateExercise(exercise); // Veritabanını güncelle
      notifyListeners();
    }
  }

  // Tüm seçimleri temizle
  void clearSelection() {
    bool hasChanges = false;
    for (var i = 0; i < _exercises.length; i++) {
      if (_exercises[i].isSelected) {
        _exercises[i] = _exercises[i].copyWith(isSelected: false);
        _repository.updateExercise(_exercises[i]); // Veritabanını güncelle
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  // Yeni egzersiz ekle
  Future<void> addExercise({
    required String title,
    required String description,
    required String category,
    required File image,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final imagePath = await _repository.saveImage(image);
      final exercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        imageUrl: imagePath,
      );

      await _repository.addExercise(exercise);
      await loadExercises(); // Listeyi yenile
    } catch (e) {
      _error = 'Egzersiz eklenirken bir hata oluştu: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Egzersiz sil
  Future<void> deleteExercise(String id) async {
    try {
      // Önce egzersizi bul
      final exercise = _exercises.firstWhere((e) => e.id == id);

      // Listeden kaldır
      _exercises.removeWhere((e) => e.id == id);
      notifyListeners();

      // Veritabanından sil
      await _repository.deleteExercise(id);

      // Resmi sil
      final imageFile = File(exercise.imageUrl);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      _error = 'Egzersiz silinirken bir hata oluştu: ${e.toString()}';
      await loadExercises(); // Hata durumunda listeyi yenile
      notifyListeners();
      rethrow;
    }
  }

  // Silinen egzersizi geri al
  Future<void> undoDelete(Exercise exercise) async {
    try {
      // Veritabanına geri ekle
      await _repository.addExercise(exercise);

      // Listeye geri ekle
      _exercises.add(exercise);
      notifyListeners();
    } catch (e) {
      _error = 'Geri alma işlemi başarısız: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Yeni getter'lar
  String? get selectedCategory => _selectedCategory;

  List<Exercise> get exercises {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      return _exercises;
    }
    return _exercises.where((e) => e.category == _selectedCategory).toList();
  }

  // Kategoriye göre filtreleme
  void filterByCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Kategori filtresini temizle
  void clearFilter() {
    if (_selectedCategory != null) {
      _selectedCategory = null;
      notifyListeners();
    }
  }

  // loadExercises metodunu güncelle
  Future<void> loadExercises() async {
    try {
      _isLoading = true;
      notifyListeners();

      _exercises = await _repository.getExercises();
      _error = null;
    } catch (e) {
      _error = 'Egzersizler yüklenirken bir hata oluştu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
