// lib/presentation/screens/add_program_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/pdf_service.dart';
import '../../data/models/program_model.dart';
import '../viewmodels/exercise_viewmodel.dart';
import '../viewmodels/program_viewmodel.dart';
import '../widgets/exercise_selection_dialog.dart';

class AddProgramScreen extends StatefulWidget {
  @override
  _AddProgramScreenState createState() => _AddProgramScreenState();
}

class _AddProgramScreenState extends State<AddProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _selectedExerciseIds = [];
  bool _isLoading = false;

  Future<void> _selectExercises() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => ExerciseSelectionDialog(
        selectedExerciseIds: _selectedExerciseIds,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedExerciseIds = result;
      });
    }
  }

  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen en az bir egzersiz seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final program = Program(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        exerciseIds: _selectedExerciseIds,
        createdAt: DateTime.now(),
      );

      await context.read<ProgramViewModel>().addProgram(program);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program oluşturulurken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate() || _selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen program adı, açıklama ve en az bir egzersiz ekleyin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('PDF oluşturuluyor...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Seçili egzersizleri al
      final exercises = context.read<ExerciseViewModel>().exercises.where((e) => _selectedExerciseIds.contains(e.id)).toList();

      final pdfFile = await PdfService.generateProgramPdf(
        programName: _nameController.text.trim(),
        programDescription: _descriptionController.text.trim(),
        exercises: exercises,
      );

      if (mounted) Navigator.pop(context); // Loading dialog'unu kapat

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Fizyoterapi Programı',
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading dialog'unu kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseViewModel = context.watch<ExerciseViewModel>();
    final selectedExercises = exerciseViewModel.exercises.where((e) => _selectedExerciseIds.contains(e.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Program'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Oluştur',
            onPressed: _generatePdf,
          ),
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              tooltip: 'Kaydet',
              onPressed: _saveProgram,
            )
          else
            Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program adı
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Program Adı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Program adı boş bırakılamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Program açıklaması
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Program Açıklaması',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Program açıklaması boş bırakılamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Seçili egzersizler
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Seçili Egzersizler',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text('${selectedExercises.length} egzersiz seçildi'),
                      trailing: TextButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Egzersiz Ekle'),
                        onPressed: _selectExercises,
                      ),
                    ),
                    if (selectedExercises.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: selectedExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = selectedExercises[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: FileImage(File(exercise.imageUrl)),
                            ),
                            title: Text(exercise.title),
                            subtitle: Text(exercise.category),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () {
                                setState(() {
                                  _selectedExerciseIds.remove(exercise.id);
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
