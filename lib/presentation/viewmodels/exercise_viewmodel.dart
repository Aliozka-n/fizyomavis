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

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

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

      // Resmi kaydet
      final imagePath = await _repository.saveImage(image);

      // Yeni egzersiz oluştur
      final exercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        imageUrl: imagePath,
        isSelected: false,
      );

      // Veritabanına kaydet
      await _repository.addExercise(exercise);

      // Listeyi güncelle
      await loadExercises();
    } catch (e) {
      print('Egzersiz eklenirken hata: $e');
      throw Exception('Egzersiz eklenirken bir hata oluştu');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Egzersiz seçimini değiştir
  void toggleExercise(String id) {
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      _exercises[index] = _exercises[index].copyWith(isSelected: !_exercises[index].isSelected);
      notifyListeners();
    }
  }

  // Tüm seçimleri temizle
  void clearSelection() {
    for (var i = 0; i < _exercises.length; i++) {
      if (_exercises[i].isSelected) {
        _exercises[i] = _exercises[i].copyWith(isSelected: false);
      }
    }
    notifyListeners();
  }

  // Egzersiz sil
  Future<void> deleteExercise(String id) async {
    try {
      final exercise = _exercises.firstWhere((e) => e.id == id);

      // Önce veritabanından sil
      await _repository.deleteExercise(id);

      // Resmi sil
      final imageFile = File(exercise.imageUrl);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Listeyi güncelle
      await loadExercises();
    } catch (e) {
      print('Egzersiz silinirken hata: $e');
      throw Exception('Egzersiz silinirken bir hata oluştu');
    }
  }

  String? _selectedCategory;

  // Getters
  String? get selectedCategory => _selectedCategory;

  // Filtrelenmiş egzersiz listesi
  List<Exercise> get exercises {
    if (_selectedCategory == null || _selectedCategory == 'Tümü') {
      return _exercises;
    }
    return _exercises.where((e) => e.category == _selectedCategory).toList();
  }

  List<Exercise> get selectedExercises => _exercises.where((e) => e.isSelected).toList();

  // Kategoriye göre filtrele
  void filterByCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Tüm egzersizleri yükle
  Future<void> loadExercises() async {
    try {
      _isLoading = true;
      notifyListeners();

      _exercises = await _repository.getExercises();
      _error = null;
    } catch (e) {
      _error = 'Egzersizler yüklenirken bir hata oluştu';
      print('Load exercises error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
