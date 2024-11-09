// lib/presentation/widgets/exercise_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/exercise_model.dart';
import '../viewmodels/exercise_viewmodel.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Egzersizi Sil'),
        content: Text('Bu egzersizi silmek istediğinizden emin misiniz?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<ExerciseViewModel>().deleteExercise(exercise.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${exercise.title} silindi'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80, right: 20, left: 20),
              action: SnackBarAction(
                label: 'Geri Al',
                onPressed: () {
                  context.read<ExerciseViewModel>().undoDelete(exercise);
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Egzersiz silinirken bir hata oluştu'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fotoğraf
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(
                        File(exercise.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                  if (exercise.isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              ),

              // İçerik
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        // Silme butonu
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          color: Colors.red,
                          tooltip: 'Egzersizi Sil',
                          onPressed: () => _confirmDelete(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      exercise.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(exercise.category),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Seçim göstergesi
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  exercise.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: exercise.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed: () {
                  context.read<ExerciseViewModel>().toggleExercise(exercise.id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
