// lib/presentation/viewmodels/program_viewmodel.dart

import 'package:flutter/foundation.dart';

import '../../data/models/program_model.dart';
import '../../data/repositories/program_repository.dart';

class ProgramViewModel extends ChangeNotifier {
  final ProgramRepository _repository;

  ProgramViewModel(this._repository) {
    loadPrograms();
  }

  List<Program> _programs = [];
  bool _isLoading = false;
  String? _error;

  List<Program> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrograms() async {
    try {
      _isLoading = true;
      notifyListeners();

      _programs = await _repository.getPrograms();
      _error = null;
    } catch (e) {
      _error = 'Programlar yüklenirken bir hata oluştu';
      print('Program loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProgram(Program program) async {
    try {
      await _repository.addProgram(program);
      await loadPrograms();
    } catch (e) {
      _error = 'Program eklenirken bir hata oluştu';
      print('Program adding error: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      await _repository.deleteProgram(id);
      await loadPrograms();
    } catch (e) {
      _error = 'Program silinirken bir hata oluştu';
      print('Program deleting error: $e');
      notifyListeners();
      rethrow;
    }
  }
}
