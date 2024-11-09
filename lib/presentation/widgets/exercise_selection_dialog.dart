// lib/presentation/widgets/exercise_selection_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/exercise_viewmodel.dart';

class ExerciseSelectionDialog extends StatefulWidget {
  final List<String> selectedExerciseIds;

  const ExerciseSelectionDialog({
    Key? key,
    required this.selectedExerciseIds,
  }) : super(key: key);

  @override
  _ExerciseSelectionDialogState createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<ExerciseSelectionDialog> {
  late List<String> _selectedIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedExerciseIds);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Egzersiz Seç',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${_selectedIds.length} seçili',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Arama alanı
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Egzersiz Ara',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),

          // Egzersiz listesi
          Consumer<ExerciseViewModel>(
            builder: (context, viewModel, child) {
              final exercises = viewModel.exercises.where((exercise) {
                if (_searchQuery.isEmpty) return true;
                return exercise.title.toLowerCase().contains(_searchQuery) ||
                    exercise.category.toLowerCase().contains(_searchQuery) ||
                    exercise.description.toLowerCase().contains(_searchQuery);
              }).toList();

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isSelected = _selectedIds.contains(exercise.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(exercise.id);
                          } else {
                            _selectedIds.remove(exercise.id);
                          }
                        });
                      },
                      title: Text(exercise.title),
                      subtitle: Text(exercise.category),
                      secondary: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(exercise.imageUrl),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Butonlar
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('İptal'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedIds);
                  },
                  child: Text('Seçilenleri Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
